module Decklistable
  extend ActiveSupport::Concern

  included do
    belongs_to :deck_list
    validate :decklist_must_parse
    attr_accessor :decklist_changed

    scope :active, lambda {
      joins(:deck_list).where(deck_lists: {enabled: true})
    }

    def enabled
      self.deck_list.enabled
    end

    def decklist
      self.deck_list && self.deck_list.as_text
    end

    def decklist=(content)
      require 'benchmark'

      return if content.blank?
      colors = []
      content = content.gsub("\r", '').split("\n")

      @decklist_error ||= []
      transaction do
        self.deck_list = DeckList.new
        content.each do |line|
          m = /^(\d+)x? +(.*)$/.match(line)
          if m
            number   = m[1].to_i
            cardname = m[2]
            if number > 0 && card = Card.select("id, name, card_type, color, enabled").find_with_varying_name(cardname)
              if deck_entry = self.deck_list.deck_entries.select{|de| de.card == card}.first
                deck_entry.amount += number
              else
                deck_entry = self.deck_list.deck_entries.build(card: card, amount: number)
              end
              deck_entry.group_type = case(card.card_type)
                                      when /(Basic |Snow )?Land( - .*)?/i
                                        'lands'
                                      when /(Artifact |Legendary |Enchantment )?Creature( - .*)?/i
                                        'creatures'
                                      else
                                        'spells'
                                      end
              col = card.color.gsub(/[^UWRGB]/, '')
              col.each_char do |c|
                colors << c
              end
            else
              @decklist_error << "Card not known: #{cardname}"
            end
          end
        end
        if self.deck_list.deck_entries.size > 0
          udi = DeckList.get_udi_by_list(DeckList.make_deck_list(self.deck_list))
          if dl = DeckList.find_by_udi(udi)
            self.deck_list = dl
          else
            self.deck_list.udi = udi
            self.deck_list.colors = colors.uniq.join('')
            self.deck_list.save!
          end
        else
          @decklist_error << "no deck entries"
        end
        self.decklist_changed = true
      end
    end

    def sideboard=(content)
      return if content.blank?
      colors = []
      content = content.gsub("\r", '').split("\n")

      @sideboard_error ||= []
      transaction do
        self.sideboard_entries.destroy_all
        content.each do |line|
          m = /^(\d+)x? +(.*)$/.match(line)
          if m
            number   = m[1].to_i
            cardname = m[2]
            if number > 0 && card = Card.find_with_varying_name(cardname)
              if deck_entry = self.sideboard_entries.select{|de| de.card == card}.first
                deck_entry.amount += number
              else
                deck_entry = self.sideboard_entries.build(card: card, amount: number)
              end
              deck_entry.group_type = case(card.card_type)
                                      when /(Basic |Snow )?Land( - .*)?/i
                                        'lands'
                                      when /(Artifact |Legendary |Enchantment )?Creature( - .*)?/i
                                        'creatures'
                                      else
                                        'spells'
                                      end
              col = card.color.gsub(/[^UWRGB]/, '')
              col.each_char do |c|
                colors << c
              end
            else
              @sideboard_error << "Card not known: #{cardname}"
            end
          end
        end
      end
    end

    def decklist_must_parse
      if @decklist_error && !@decklist_error.empty?
        @decklist_error.each do |e|
           self.errors.add(:base, e)
        end
        return false
      else
        return true
      end
    end
  end
end
