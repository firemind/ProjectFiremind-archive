class KaladeshRotation < ActiveRecord::Migration
  def change
    return if Rails.env.test?

      affected_formats = %w(Standard Modern Vintage Legacy Pauper).map do |name| 
        f = Format.where(name: name).first
        f.format_type = name.downcase
        f.save!

        set = name.downcase.to_sym
        card_ids = []
        if set == :standard
          Edition.where(standard_legal: true).each do |ed|
            card_ids |= ed.card_prints.collect(&:card_id)
          end
        elsif set == :modern
          Edition.where(modern_legal: true).each do |ed|
            card_ids |= ed.card_prints.collect(&:card_id)
          end
        elsif set == :pauper
          Edition.all.each do |ed|
            card_ids |= ed.card_prints.where(rarity: 'common').collect(&:card_id)
          end
        else
          Edition.all.each do |ed|
            card_ids |= ed.card_prints.collect(&:card_id)
          end
        end

        card_ids -= RestrictedCard.where(format_id: f.id, limit: 0).pluck :card_id
        f.legalities = ~Card.full_binary(card_ids)
        f.save!
        f
      end


      FormatUpdater.perform(
        set_changes: {
          standard: {
            added: ["KLD"],
            removed: ["DTK", "ORI"]
          },
          modern: {
            added: ["KLD"]
          },
          legacy: {
            added: ["KLD"]
          },
          pauper: {
            added: ["KLD"]
          },
          vintage: {
            added: ["KLD"]
          }
        }
      )
  end
end
