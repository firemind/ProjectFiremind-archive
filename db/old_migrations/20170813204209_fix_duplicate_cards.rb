class FixDuplicateCards < ActiveRecord::Migration[5.1]
  def change
    return if Rails.env.test?
    fix_card 411032, 411079
    fix_card 63088, 63166
    fix_card 63089, 63167
    fix_card 63090, 63168
    fix_card 63091, 63169
    fix_card 63092, 63170
    fix_card 63093, 63171
    fix_card 63094, 63172
    fix_card 63095, 63173
    fix_card 63096, 63174
    fix_card 63097, 63175
    fix_card 63098, 63176
    fix_card 63099, 63177
    fix_card 63100, 63178

    fix_card 411032, 411079
    fix_card 411033, 411080
    fix_card 411034, 411081
    fix_card 411035, 411082
    fix_card 411036, 411083
    fix_card 411037, 411084
    fix_card 411038, 411085
    fix_card 411039, 411086
    fix_card 411040, 411087
    fix_card 411041, 411088
    fix_card 411042, 411089
    fix_card 411043, 411090
    fix_card 411044, 411091
    fix_card 411045, 411092
    fix_card 411046, 411093

  end
  def fix_card(old, new)
    DeckEntry.where(card_id: old).update_all(card_id: new)
    RestrictedCard.where(card_id: old).update_all(card_id: new)
    Ruling.where(card_id: old).update_all(card_id: new)
    CardRequest.where(card_id: old).update_all(card_id: new)

  end
end
