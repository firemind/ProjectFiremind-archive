class Archetype < ApplicationRecord
  belongs_to :format
  has_many :deck_lists, dependent: :nullify
  has_many :decks, through: :deck_lists
  has_many :deck_entries, through: :deck_lists
  has_many :cards, through: :deck_entries
  has_many :card_prints, through: :cards
  has_many :mulligan_decisions, through: :deck_lists
  has_many :human_deck_lists, class_name: 'DeckList', foreign_key: "human_archetype_id", dependent: :nullify
  has_many :meta_fragments, dependent: :destroy
  has_many :archetype_aliases, dependent: :destroy
  has_many :sideboard_plans, dependent: :destroy
  belongs_to :thumb_print, class_name: "CardPrint"
  accepts_nested_attributes_for :archetype_aliases, allow_destroy: true
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :format_id

  scope :no_archetype, ->(){
    where(name: "No Archetype")
  }

  scope :ordered_by_num_games, ->(){
    joins(:deck_lists).
    order("sum(won_games_count)+sum(lost_games_count) desc").
    group("archetypes.id")
  }

  scope :full_text_search_with_aliases, ->(query) do
    left_joins(:archetype_aliases).where("match(archetypes.name) against (:q IN NATURAL LANGUAGE MODE) or match(archetype_aliases.name) against (:q IN NATURAL LANGUAGE MODE)", q: query)
  end

  def mulligan_percentage
    mulligan_decisions.where(mulligan: true).count.to_f / mulligan_decisions.count
  end

  def game_count_against(op)
    my_ids = deck_lists.select(:id).map &:id
    op_ids = op.deck_lists.select(:id).map &:id
    Game.where("(winning_deck_list_id in (?) and losing_deck_list_id in (?)) or (losing_deck_list_id in (?) and winning_deck_list_id in (?))", my_ids, op_ids, my_ids, op_ids).count
  end

  def win_count_against(op)
    my_ids = deck_lists.select(:id)
    op_ids = op.deck_lists.select(:id)
    Game.where("winning_deck_list_id in (#{my_ids.to_sql}) and losing_deck_list_id in (#{op_ids.to_sql})").count
  end

  def loss_count_against(op)
    op.win_count_against(self)
  end

  def legal_deck_lists
    deck_lists.legal_in
  end

  def merge_into(to)
    human_deck_lists.update_all(human_archetype_id: to.id)
    deck_lists.update_all(archetype_id: to.id)
    Misclassification.where(predicted_id: self.id).delete_all
    Misclassification.where(expected_id:  self.id).delete_all
    archetype_aliases.update_all(archetype_id: to.id)
    MetaFragment.where(archetype_id:  self.id).update_all(archetype_id: to.id)
    SideboardPlan.where(archetype_id:  self.id).destroy_all
    to.archetype_aliases.create(name: self.name)
    self.destroy
  end

  def calculate_thumb
		deck_entries = DeckEntry.joins(:deck_list).where(deck_lists: {human_archetype_id: self.id}).where.not(card_id: Card.basics.pluck(:id)).select("card_id, sum(amount) as copy_count, count(deck_list_id) as dl_count, group_type").group("card_id, group_type").includes(:card)

		deck_lists = self.deck_lists
		dl_count = deck_lists.count
		return if dl_count == 0
		cards = deck_entries.sort_by{|de|
			number_of_copies_per_deck= de.copy_count.to_f / de.dl_count
			percent_of_decks= de.dl_count.to_f / dl_count
      occurs_in_deck_lists = DeckEntry.joins(deck_list: :human_archetype).
        where(card_id: de.card_id).
        where(archetypes: {format_id: self.format_id}).
				where.not(deck_lists: {human_archetype_id: self.id}).
        count
      other_lists = DeckList.joins(:human_archetype).where.not(human_archetype_id: self.id).where(archetypes: {format_id: self.format_id}).count
      occurence_in_others = occurs_in_deck_lists.to_f / (other_lists+1)

			factor = de.group_type== 'lands' ? 0.7 : 1
			(number_of_copies_per_deck/4 + percent_of_decks - occurence_in_others)*factor
		}.reverse
		cards.each do |c|
			cp = c.card.card_prints.where(has_crop: true).last
			if cp
				self.thumb_print = cp
				return
			end
		end
  end

  def to_s
    name
  end

  def self.find_with_alias(name, format_id)
    name.gsub!(/[^a-zA-Z0-9 \/&\(\)-]/, '')
    name.gsub!("Mono-", "Mono ")
    name.gsub!("Mono U ", "Mono Blue ")
    name.gsub!("Mono R ", "Mono Red ")
    name.gsub!("Mono W ", "Mono White ")
    name.gsub!("Mono G ", "Mono Green ")
    name.gsub!("Mono B ", "Mono Black ")
    colormap = {r: 'Red', w: 'White', b: 'Black', g: 'Green', u: 'Blue'}
    name.gsub!(/^([rwbgu])\/?([rwbgu]) /i){|m| "#{colormap[$1.downcase.to_sym]}-#{colormap[$2.downcase.to_sym]} " } 
    if aa = ArchetypeAlias.joins(:archetype).where(name: name, archetypes: {format_id: format_id}).first
      return aa.archetype
    else
      where(name: name, format_id: format_id).first
    end
  end

  def self.alias_mapping
    {
      'Naya Zoo' => 'Zoo',
      'Jeskai Black' => 'Dark Jeskai',
      'Red-Green Landfall' => 'R/G Landfall',
      'Blue-Red Twin' => "U/R Twin",
      'UR Twin' => "U/R Twin",
      'Splinter Twin' => "U/R Twin",
      'Bring to Light Control' => '5c Bring to Light',
      'Red Aggro' => 'Mono Red Aggro',
      'Mono-Green Aggro' => 'Mono Green Stompy',
      'RUG Delver' => 'Temur Delver',
      'UR Delver' => 'U/R Delver',
      'Junk' => 'Abzan',
      'Death & Taxes' => 'Death and Taxes',
      'Mono-White Hatebears' => 'Death and Taxes',
      'UR Storm' => 'Storm',
      'Green Ramp' => 'Mono G Eldrazi',
      'WU Merfolk' => 'UW Merfolk',
      'Mono Red Aggro ' => 'Mono Red Burn',
      'Burn' => 'Mono Red Burn',
      'Jeskai Midrange' => 'Jeskai',
      'UWR Miracles' => 'Miracles',
      'Suicide Zoo' => 'Zoo-icide',
      'Jund Suicide Zoo' => 'Zoo-icide',
      'Painter' => 'Imperial Painter',
      'Oath of Druids' => 'Grisel Oath',
      'Sultai Delver' => 'BUG Delver',
      'BW Eldrazi' => 'B/W Eldrazi',
      'Azorius Control' => 'U/W Control',
      'UWR Delver' => 'Jeskai Delver',
      'W/B Eldrazi' => 'B/W Eldrazi',
      'Faeries' => 'Blue-Black Faeries',
      'UG 12-Post' => '12-Post',
      'C Eldrazi' => 'Colorless Eldrazi',
    }
  end

  def league_result_count(wins=5, losses=0)
    deck_lists.
      joins(decks: {tournament_result: :tournament}).
      where(tournament_results: {wins: wins, losses: losses},tournaments: {format_id: format_id, tournament_type: "Competitive #{format.format_type} League"}).count
  end

  def challenge_result_count(wins=7, losses=0)
    deck_lists.
      joins(decks: {tournament_result: :tournament}).
      where(tournament_results: {wins: wins, losses: losses},tournaments: {format_id: format_id, tournament_type: "Challenge"}).count
  end

  def top_cards(num= 3)
    deck_entries = DeckEntry.joins(:deck_list).where(deck_lists: {archetype_id: self.id}).select("card_id, sum(amount) as copy_count").group("card_id").order("copy_count desc").limit(num).includes(:card).map &:card
  end

  scope :order_by_highest_rating_in, ->(format){
    joins("LEFT JOIN `deck_lists` ON `deck_lists`.`archetype_id` = `archetypes`.`id` LEFT JOIN `ratings` ON `ratings`.`deck_list_id` = `deck_lists`.`id` and ratings.format_id = #{format.id}").
    select("archetypes.*, max(ratings.whr_rating) as highest_rating").
    order("highest_rating desc").
    group("archetypes.id")
  }
end
