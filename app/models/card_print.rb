class CardPrint < ApplicationRecord
  belongs_to :edition
  belongs_to :card
  validates_presence_of :card, :edition
  has_many :price_changes, dependent: :destroy

  delegate :name, to: :card

  scope :implemented, ->(){
    joins(:card).where(cards: {enabled: true})
  }

  scope :with_image, ->(){
    where(with_image: true)
  }

  scope :with_thumb, ->(){
    where(has_thumb: true)
  }

  def to_s
    "#{card.name} (#{edition.short})"
  end

  def clean_cardname
    self.card.name.gsub("ö","o").gsub("Æ","Ae").gsub("é","e").gsub("â","a").gsub("û","u").gsub("ú","u").gsub("í","i").gsub("á","a").gsub("à","a")
  end

  def update_prices
    request = http_get("magictcgprices.appspot.com", "/api/tcgplayer/price.json", {cardname: clean_cardname, cardset: self.edition.name })
    #request = http_get("magictcgprices.appspot.com", "/api/cfb/price.json", {cardname: self.name, setname: self.edition.name })
    prices = JSON.parse(request)
    if prices.first.length > 0
      new_l = prices[0].gsub('$','').to_f
      new_m = prices[1].gsub('$','').to_f
      new_h = prices[2].gsub('$','').to_f
      if self.price_low && self.price_low != new_l
        pc = self.price_changes.build(price_type: 'price_low', original_value: self.price_low, new_value: new_l, change_in_percent: price_diff_ratio(self.price_low, new_l) )
        pc.save!
      end
      if self.price_mid && self.price_mid != new_m
        new_m_ratio = price_diff_ratio(self.price_mid, new_m)
        pc = self.price_changes.build(price_type: 'price_mid', original_value: self.price_mid, new_value: new_m, change_in_percent: new_m_ratio)
        pc.save!
        puts "Price m changed by #{new_m_ratio > 0 ? '+' : '-'}#{new_m_ratio} for #{self.name} #{self.edition.name}" if new_m_ratio.abs > 3
      end
      if self.price_high && self.price_high != new_h
        pc = self.price_changes.build(price_type: 'price_high', original_value: self.price_high, new_value: new_h, change_in_percent: price_diff_ratio(self.price_high, new_h))
        pc.save!
      end
      self.price_low = new_l
      self.price_mid = new_m
      self.price_high = new_h
    else
      puts "No prices for #{self.name} #{self.edition.name}"
      self.price_low = 0
      self.price_mid = 0
      self.price_high = 0
    end
    return prices
  end

  def update_price!(raw_new_price, type: 'price_mid', source: 'unknown')
    new_price = raw_new_price.to_f.round(PRICE_PRECISION)
    raise "Not a valid price #{new_price}" if new_price == 0.0
    old_price = send("#{type}")
    if old_price && old_price != new_price
      new_ratio = self.class.price_diff_ratio(old_price, new_price)
      pc = price_changes.build(price_type: type, original_value: old_price, new_value: new_price, change_in_percent: new_ratio, source: source)
      pc.save!
    end
    send("#{type}=", new_price)
    save!
  end

  def get_relative_id
    (nr_in_set && nr_in_set.to_i > 0) ? nr_in_set : multiverse_id
  end

  private
  def http_get(domain,path,params)
    paramstring = "#{path}?".concat(params.collect { |k,v| "#{k}=#{URI.escape(v.to_s)}" }.join('&'))
    return Net::HTTP.get(domain, paramstring) if not params.nil?
    return Net::HTTP.get(domain, path)
  end

  def self.price_diff_ratio(old_p, new_p)
    if old_p > 0
      new_m_diff = new_p - old_p
      new_m_ratio = (new_m_diff.abs / old_p)*100
    else
      new_m_ratio = new_p > 0 ? 100 : 0
    end
    return new_m_ratio
  end



end
