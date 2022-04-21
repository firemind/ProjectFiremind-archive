json.decks @decks do |d|
  json.id d.deck_list_id
  json.title d.title
  json.avatar ActionController::Base.helpers.image_url("avatars/#{d.avatar}")
  json.list_excerpt render(partial: "duels/deck_quick_stats", locals: {deck_list: d.deck_list}, formats: :html)
end
