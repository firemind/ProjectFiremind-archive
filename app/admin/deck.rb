ActiveAdmin.register Deck do

  filter :title
  filter :format
  filter :format_id, as: :check_boxes, collection: proc { Format.enabled }
  filter :deck_list_enabled, as: :check_boxes

  batch_action :make_archetype do |selection|
    d = Deck.find(selection).first
    at = Archetype.create!(format_id: d.format_id, name: d.title )
    at.calculate_thumb
    at.save
    redirect_to admin_archetype_path(at)
  end

  index do
    selectable_column
    column :title
    column :author
    column :format
    column :created_at
    column :forked_from
    column :decklist
    column :public
    actions
  end




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
