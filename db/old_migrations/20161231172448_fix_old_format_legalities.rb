class FixOldFormatLegalities < ActiveRecord::Migration[5.0]
  def change
    Format.where("name like ?", "Modern %").each do |modern|
      last_edition = Edition.where(short: modern.name.split(" ").last).first
      recalc_legality_for(modern, Edition.where(modern_legal: true).where("created_at <= ?", last_edition.created_at).inject([]) { |card_ids, ed|
        card_ids |= ed.card_prints.collect(&:card_id)
      })
    end
    Format.where("name like ?", "Standard %").each do |standard|
      recalc_legality_for(standard,Edition.where(short: standard.name.split(" ").last.split('-')).inject([]) do |card_ids, ed|
        card_ids |= ed.card_prints.collect(&:card_id)
      end)
    end
    Format.where("name like ?", "Pauper %").each do |pauper|
      last_edition = Edition.where(short: pauper.name.split(" ").last).first
      recalc_legality_for(pauper, Edition.where("created_at <= ?", last_edition.created_at).inject([]) do |card_ids, ed|
        card_ids |= ed.card_prints.where(rarity: 'common').collect(&:card_id)
      end)
    end
    Format.where("name like ?", "Vintage %").each do |vintage|
      last_edition = Edition.where(short: vintage.name.split(" ").last).first
      recalc_legality_for(vintage, Edition.where("created_at <= ?", last_edition.created_at).inject([]) do |card_ids, ed|
        card_ids |= ed.card_prints.collect(&:card_id)
      end)
    end
    Format.where("name like ?", "Legacy %").each do |legacy|
      last_edition = Edition.where(short: legacy.name.split(" ").last).first
      recalc_legality_for(legacy, Edition.where("created_at <= ?", last_edition.created_at).inject([]) do |card_ids, ed|
        card_ids |= ed.card_prints.collect(&:card_id)
      end)
    end
  end

  def recalc_legality_for(format, card_ids)
    puts format
    card_ids -= RestrictedCard.where(format_id: format, limit: 0).pluck :card_id

    format.legalities = Card.full_binary(card_ids)
    format.save!
  end
end
