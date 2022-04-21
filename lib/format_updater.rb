class FormatUpdater
  #       standard: {
  #         added: ["SOI"],
  #         removed: ["KTK", "FRF"]
  #       }
  #       br_updates: {
  #       modern: {
  #         banned: {
  #           additions: [
  #             "Eye of Ugin"
  #           ],
  #           removals: [
  #             "Ancestral Visions",
  #             "Sword of the Meek" 
  #           ]
  #         }
  #       },
  def self.perform(br_updates: {}, set_changes: {}, br_name: nil)
    ActiveRecord::Base.transaction do
      changed_formats = br_updates.keys | set_changes.keys
      changed_formats.each do |formatname|
        puts formatname
        format= Format.where(format_type: formatname, enabled: true).first
        card_ids = []

        new_editions = format.editions.to_a

        if changes = set_changes.delete(formatname)
          (changes[:added] || []).each do |name|
            new_editions << Edition.where(short: name).first
          end
          (changes[:removed] || []).each do |name|
            new_editions.delete Edition.where(short: name).first
          end
        end

        format.name = if format == :standard
          "#{format.name} #{format.editions.order(:release_date).map(&:short).join("-")}"
        else
          "#{format.name} #{format.editions.order(:release_date).last.short}"
        end
        if br_name
          format.name += " pre B&R Update #{br_name}"
        end
        format.enabled = false
        format.save!
        

        fnew = Format.new({
          name: formatname.capitalize,
          enabled: true,
          auto_queue: format.auto_queue,
          min_deck_size: format.min_deck_size,
          max_deck_size: format.max_deck_size,
          max_copies: format.max_copies,
          format_type: format.format_type,
          description: format.description,
        })

        fnew.editions = new_editions
        fnew.save!

        duplicate_br(fnew, format)
        
        adjust_br(fnew, br_updates.delete(formatname))

        card_ids = fnew.editions.inject([]) { |ids, ed|
          if format.format_type.to_s.downcase == 'pauper'
            ids |= ed.card_prints.where(rarity: 'common').pluck(:card_id)
          else
            ids |= ed.card_prints.pluck(:card_id)
          end
        }
        card_ids -= RestrictedCard.where(format_id: fnew.id, limit: 0).pluck :card_id
        fnew.legalities = Card.full_binary(card_ids)
        fnew.save!

        recalc_deck_list_legality(format, fnew)

        copy_archetypes(format, fnew)
        
      end
      puts set_changes.inspect
      puts br_updates.inspect
    end
  end

  private

  def self.duplicate_br(fnew, format)
    format.restricted_cards.each do |card|
      card_new = card.dup
      card_new.format_id = fnew.id
      card_new.save!
    end
  end

  def self.adjust_br(fnew, br_change)
    if br_change
      if banned = br_change[:banned]
        (banned[:additions] || []).each do |card_name|
          card = Card.where(name: card_name).first!
          raise "BR card already on list #{fnew} #{card_name}" if fnew.restricted_cards.where(card_id: card.id, limit: 0).first
          RestrictedCard.create(format_id: fnew.id, card_id: card.id, limit: 0)
        end
        (banned[:removals] || []).each do |card_name|
          card = Card.where(name: card_name).first!
          raise "BR card not on list #{fnew} #{card_name}" unless rc = fnew.restricted_cards.where(card_id: card.id, limit: 0).first
          rc.destroy
        end
      end
      if restricted= br_change[:restricted]
        (restricted[:additions]||[]).each do |card_name|
          card = Card.where(name: card_name).first!
          raise "BR card already on list #{fnew} #{card_name}" if fnew.restricted_cards.where(card_id: card.id, limit: 1).first
          RestrictedCard.create(format_id: fnew.id, card_id: card.id, limit: 1)
        end
        (restricted[:removals]||[]).each do |card_name|
          card = Card.where(name: card_name).first!
          raise "BR card not on list #{fnew} #{card_name}" unless rc = fnew.restricted_cards.where(card_id: card.id, limit: 1).first
          rc.destroy
        end
      end
    end
  end

  def self.recalc_deck_list_legality(format, fnew)
    progress_bar = ProgressBar.new(format.deck_lists.count)
    format.deck_lists.includes(:deck_entries).find_each(batch_size: 100) do |dl|
      FormatCalcWorker.new.process_dl(dl, nolog: true, formats: [fnew.id])
      progress_bar.increment
    end
    format.decks.joins(deck_list: :formats).where(deck_lists_formats: {format_id: fnew.id}).update_all(format_id: fnew.id)
  end

  def self.copy_archetypes(format, fnew)
    format.archetypes.each do |at|
      anew = at.dup
      anew.format_id = fnew.id
      anew.has_banner = false
      anew.save!
      at.archetype_aliases.each do |al|
        alnew = al.dup
        alnew.archetype_id = anew.id
        alnew.save!
        anew.archetype_aliases << alnew
      end
      at.deck_lists.joins(:formats).where(formats: {id: fnew.id}).update_all(archetype_id: anew.id)
      at.human_deck_lists.joins(:formats).where(formats: {id: fnew.id}).update_all(human_archetype_id: anew.id)
    end
  end
end
