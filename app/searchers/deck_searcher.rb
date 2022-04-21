class DeckSearcher
  attr_accessor :cards, :ambig_cards, :ambig_archetypes, :format, :archetype, :errors, :terms
	def initialize(query)
    self.errors = []
    self.cards = []
    self.ambig_cards = []
    self.ambig_archetypes = []
    @query = query.to_s.strip
    terms = filter_terms(@query)
    if format_name = terms[:format]
			if f = Format.where("name like :name", name: format_name).first
				self.format = f
			else
				errors << "No such format"
			end
    end
    if archetype_name = terms[:archetype]
      self.archetype = find_archetype(archetype_name)
	  end
  end


  def query
    self.apply_query
    if self.archetype
      extend_filter Deck.joins(:deck_list).where(deck_lists: {archetype_id: self.archetype.id}).pluck("decks.id")
    end
    if self.format
      extend_filter Deck.where(format_id: self.format.id).pluck("decks.id")
    end
    if self.terms[:rating_gt] || self.terms[:rating_lt]
      s = Deck.joins(deck_list: :ratings)
      s = self.format ? s.where(ratings: {format_id: self.format.id}) : s.where("ratings.format_id = decks.format_id")
      if self.terms[:rating_gt]
        s = s.where("ratings.whr_rating > ?", self.terms[:rating_gt])
      end
      if self.terms[:rating_lt]
        s = s.where("ratings.whr_rating < ?", self.terms[:rating_lt])
      end
      extend_filter s.pluck("decks.id")
    end
    self.cards.each do |card|
      extend_filter Deck.by_card(card).pluck("decks.id")
    end
		Deck.includes([:author, {deck_list: :archetype}, :format]).where(id: @filtered_ids)
  end

  def suggestions
    established = @query.split[0..-2]
    unfinished  = @query.split[-1]
    sugs = []
    unless @query.blank?
      if unfinished.include? ':'
        keyword, keyword_search = unfinished.split(':')
        case keyword.to_sym
          when :format
            if keyword_search.blank?
              sugs += Format.enabled.map {|f| "format:#{f}"}
            else
              sugs += Format.where("name like ?", "#{keyword_search}%").map {|f| keyword_pair :format, f.name}
            end
          when :archetype
            unless keyword_search.blank?
              archetypes = search_archetypes(keyword_search).limit(10)
              sugs += archetypes.map {|a| keyword_pair :archetype, a.name}
            end
          when :card
            unless keyword_search.blank?
              cards = search_cards(keyword_search).limit(10)
              sugs += cards.map {|a| keyword_pair :card, a.name}
            end
        end
      else
        archetypes = search_archetypes(unfinished).limit(10)
        sugs += archetypes.map {|a| keyword_pair :archetype, a.name}
        decks = search_decks(unfinished)
        sugs += decks.map &:title
      end
    end

    sugs.map{|s| [established, s].join(" ")}
  end

  def keyword_pair(keyword, value)
    "#{keyword}:#{value.gsub(' ', '_')}"
  end

  def terms_without(cards: [], format: nil, archetype: nil, general: nil)
    mod_terms = terms.deep_dup
    mod_terms[:card] -= cards.map &:name
    mod_terms.delete(:format)    if format
    mod_terms.delete(:archetype) if archetype
    mod_terms[:general] = []     if general
    terms_as_string(mod_terms)
  end

  def terms_with(cards: [], format: nil, archetype: nil, general: nil)
    mod_terms = terms.deep_dup
    mod_terms[:card] += cards.map &:name
    mod_terms[:format] = format.name if format
    mod_terms[:general] = general     if general
    mod_terms[:archetype] = archetype.name if archetype
    terms_as_string(mod_terms)
  end

  def terms_as_string(the_terms=self.terms)
    the_terms.map do |k, v|
      if k == :general
        v
      elsif k == :card
        v.map {|c| "card:#{c.gsub(' ', '_')}"}.join(" ")
      else
        "#{k}:#{v.to_s.gsub(' ', '_')}"
      end
    end.join(" ").strip
  end

  protected
  def find_archetype(archetype_name, exact: true)
    archetype_name = archetype_name.gsub('_', ' ')
		s = self.format ? self.format.archetypes : Archetype.where(format_id: Format.enabled.pluck(:id))
    if exact
      archetypes = s.where("name like :name", name: archetype_name)
    else
      unless (archetypes = s.left_joins(:archetype_aliases).where("archetypes.name like :name or archetype_aliases.name like :name", name: "#{archetype_name}%")).any?
        archetypes = search_archetypes(archetype_name)
      end
    end
		if archetypes.size == 1
			return archetypes.first
		elsif archetypes.size == 0
			errors << "No such archetype" if exact
			return nil
		else
			self.ambig_archetypes = archetypes
      return nil
		end
  end

  def filter_terms(query)
    self.terms = {
        card: []
    }
    self.terms[:general] = []
		query.gsub(/: +/, ':').split.each do |search_term|
			next if search_term.blank?
			(keyword, keyword_search) = search_term.split(':')
			if keyword_search
        name = keyword_search.gsub('_', ' ')
        if %q(card).include? keyword
          terms[keyword.to_sym] << name
        elsif %q(format archetype).include? keyword
          terms[keyword.to_sym] = name
        elsif %q(rating_gt rating_lt).include? keyword
          terms[keyword.to_sym] = keyword_search.to_i
        else
					self.errors << "Unknown keyword #{keyword_search}"
				end
			else # basic search
        self.terms[:general] << search_term
			end
		end
    terms
  end

  def search_cards(name)
    name = sanitize_string_fulltext_search(name.gsub('_', ' ')).strip
    if name.blank?
      Card.none
    else
      Card.full_text_search_name(name+"*")
    end
  end

  def search_decks(name)
    if (decks =Deck.where(title: name)).any?
      decks
    elsif (decks =Deck.where("title like ?", "#{name}%")).any?
      decks
    else
      name = sanitize_string_fulltext_search(name.gsub('_', ' ')).strip
      if name.blank?
        Deck.none
      else
        Deck.full_text_search(name+"*")
      end
    end
  end

  def search_archetypes(name)
    name = sanitize_string_fulltext_search(name.gsub('_', ' ')).strip
    if name.blank?
      Card.none
    else
      s = self.format ? self.format.archetypes : Archetype.where(format_id: Format.enabled.pluck(:id))
      s.full_text_search_with_aliases(name+"*")
    end
  end

  def sanitize_string_fulltext_search(str)
    str.gsub(/[^\p{L}\p{N}_]+/u, ' ')
  end

  def extend_filter(ids)
    if @filtered_ids
      if @filtered_ids.any?
        @filtered_ids &= ids
      end
    else
      @filtered_ids = ids
    end
  end

  def apply_query

    if card_names = terms[:card]
      card_names.each do |card_name|
				if card = Card.where(name: card_name).first
					self.cards << card
				elsif (cards = search_cards(card_name).limit(5)).size == 1
					self.cards << cards.first
        else
          terms[:card].delete(card_name)
					self.ambig_cards += cards
				end
      end
    end
    if self.terms[:general].any?
      search_term = self.terms[:general].join(' ')
      if self.archetype.nil? && at = find_archetype(search_term, exact: false)
        self.archetype = at
      elsif (res = search_decks(search_term)).any?
        extend_filter res.pluck(:id)
      end
    end
  end
end
