ActiveAdmin.register CardScriptClaim do
  index do
    selectable_column
    id_column
    column :card
    column :user
    column :created_at
    actions
  end


end

