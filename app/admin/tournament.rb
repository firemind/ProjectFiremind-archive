ActiveAdmin.register Tournament do
  filter :format
  filter :identifier
  filter :tournament_type

  form do |f|
    f.inputs  do
      f.input :tournament_type
      f.input :nr
    end
    f.inputs do
      f.has_many :tournament_results, :allow_destroy => true, :new_record => true do |cf|
        cf.input :wins
        cf.input :losses
        cf.input :mtgo_nick
      end
    end
    f.actions
  end
  show do |ad|
    attributes_table do
      row :id
      row :name
      row :format
    end
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
