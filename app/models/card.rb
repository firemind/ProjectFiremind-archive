class Card < ApplicationRecord
  has_many :deck_entries, dependent: :restrict_with_error
  has_many :deck_lists, through: :deck_entries
  has_many :ratings, through: :deck_lists
  has_many :archetypes, through: :deck_lists
  has_many :card_requests, dependent: :restrict_with_error
  has_many :card_prints, dependent: :restrict_with_error
  accepts_nested_attributes_for :card_prints
  has_many :rulings, dependent: :destroy
  has_many :restricted_cards, dependent: :destroy
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :not_implementable_reasons, -> { distinct }
  belongs_to :config_updater, class_name: "User"
  belongs_to :primary_print, class_name: "CardPrint"

  validates_presence_of :name, :cmc, :card_type

  validates_uniqueness_of :name

  validate do
    if enabled && added_in_next_release
      errors.add :added_in_next_release, "can't be added to already enabled card"
    end
  end

  validate do
    if primary_print_id_changed? && primary_print
      unless self.card_prints.include? primary_print
        self.errors.add(:primary_print, "has to be in card prints")
      end
    end
  end

  scope :basics, ->(){
    where(name: [
      'Swamp',
      'Mountain',
      'Forest',
      'Plains',
      'Island',
      'Wastes',
      'Snow-Covered Swamp',
      'Snow-Covered Mountain',
      'Snow-Covered Forest',
      'Snow-Covered Plains',
      'Snow-Covered Island',
    ])
  }

  after_save do
    if self.saved_change_to_enabled?
      self.deck_entries.map(&:deck_list).each do |dl|
        dl.set_enabled
        dl.save
      end
    end
  end


  scope :enabled, -> { where(enabled: true) }
  scope :added_in_next_release, -> { where(added_in_next_release: true) }

  scope :full_text_search, ->(query) do
    where("match(name, ability) against (? IN NATURAL LANGUAGE MODE)", query)
  end

  scope :full_text_search_name, ->(query) do
    where("match(name) against (? IN NATURAL LANGUAGE MODE)", query)
  end

  scope :in_decks, ->() do
    joins(:deck_entries).group("cards.id").having("count(deck_entries.id) > 0")
  end

  def calc_magarena_rating!
    self.magarena_rating = ratings.average(:whr_rating)
    self.save(validate: false)
  end

  def edition
    card_prints.last.edition
  end

  def self.sorted_ids
    @@sorted_ids ||= order("id").pluck(:id)
  end

  def self.full_binary(card_ids)
    @exp = -1
    Card.sorted_ids.inject(0) {|total, id|
      @exp += 1
      total += 2**@exp if card_ids.include? id
      total
    }
  end

  def self.card_ids_at(binary)
    ids = Card.sorted_ids.to_a
    s = binary.to_s(2).reverse
    (0 ... s.length).find_all { |i| s[i] == '1' }.map{ |i|
      ids[i]
    }
  end

  def variation
    card_prints.last.variation
  end

  def self.find_with_varying_name(name)
    name = name.gsub(/Æ/,'Ae')
    card = self.where(name: name).first
    unless card
      card = self.where(flip_name: name).first
    end
    unless card
      a,b = name.split('/')
      if b 
        card = self.where("name like ?", "#{a} // #{b}").first
      else
        card = self.where("name like ? or name like ?", "#{name} // %", "% // #{name}").first
      end
    end
    return card
  end

  def set_code(set_code, set = "")
    ed= Edition.find_by_short(set_code) || Edition.create(short:set_code, name: set)
    self.edition = ed
  end

  def as_indexed_json(options={})
    as_json(only: [
      :name,
      :ability
    ])
  end

  def to_s
    name
  end

  def self.encode_cardname(cardname)
    cardname.gsub(":","").gsub("ö","o").gsub("Æ","Ae").gsub("é","e").gsub("â","a").gsub("û","u").gsub("ú","u").gsub("í","i").gsub("á","a").gsub(" // ","")
  end

  def not_limited?
    [
      'Swamp',
      'Mountain',
      'Forest',
      'Plains',
      'Island',
      'Wastes',
      'Snow-Covered Swamp',
      'Snow-Covered Mountain',
      'Snow-Covered Forest',
      'Snow-Covered Plains',
      'Snow-Covered Island',
      'Relentless Rats',
      'Shadowborn Apostle'
    ].include? name
  end

  def config_script
    try_read_script_config self.script_name
  end

  def groovy_script
    try_read_script_config self.groovy_script_name
  end

  def missing_config_script
    try_read_script_config self.script_name, missing: true
  end

  def missing_groovy_script
    try_read_script_config self.groovy_script_name, missing: true
  end

  def groovy_script_name
    "#{self.script_name.split(".")[0]}.groovy"
  end

  def script_name
    "#{self.name.gsub(/[^A-Za-z0-9]/, "_")}.txt"
  end

  def basic?
    !! (self.card_type =~ /^Basic (Snow )?Land/i)
  end

  def land?
    !! (self.card_type =~ /^(Basic |Snow )?Land/i)
  end

  def self.mlbot_mapped_edition(edition_name)
    MLBOT_EDITION_MAPPING[edition_name] || edition_name
  end

  def mlbot_edition
    edition_name = edition.short
    MLBOT_EDITION_MAPPING.invert[edition_name] || edition_name
  end

  def french_vanilla?
    text = self.ability.dup
    keywords.each do |kw|
      text.gsub!(kw.name,"")
    end
    text.gsub!(/\(.*\)/,"")
    text.gsub(/[^a-zA-Z]/,"").blank?
  end

  def french_combat_vanilla?
    text = self.ability.dup
    keywords.where(combat_relevant: true).each do |kw|
      text.gsub!(kw.name,"")
    end
    text.gsub!(/\(.*\)/,"")
    text.gsub(/[^a-zA-Z]/,"").blank?
  end

  private 

  def try_read_script_config(file_name, missing: false)
    path =  missing ? "release/Magarena/scripts_missing/" : "release/Magarena/scripts/"
    filename = File.join(Rails.configuration.x.magarena_tracking_repo, path,file_name)
    if File.exists?(filename)
      File.read filename
    else
      Rails.logger.debug("No script under #{filename}")
      nil
    end
  end
end

