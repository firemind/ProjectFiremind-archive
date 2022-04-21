ActiveAdmin.register Edition do

  index do
    selectable_column
    id_column
    column :name
    column :short
    column :release_date
    column :synced_at
    column :mtgo
    actions
  end

  filter :name
  filter :short

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name, :short, :mtgo
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
