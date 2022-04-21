ActiveAdmin.register Duel do
  filter :status

  index do
    actions
    column :games_played
    column :games_to_play
    column :state
    column :format
    column :deck_list1
    column :deck_list2
    column :decks_valid_in do |r|
      if r.freeform
        true
      else
        r.deck_list1&.legal_in?(r.format) && r.deck_list2&.legal_in?(r.format)
      end
    end
    column :wins_deck1
    column :wins_deck2
    column :created_at
    column :updated_at
    column :public
    column :failure_message
    column :error_acknowledged
    column :card_script_submission
  end

  filter :format_id, as: :check_boxes, collection: proc { Format.enabled }

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
