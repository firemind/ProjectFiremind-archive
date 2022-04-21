ActiveAdmin.register Keyword do
  batch_action :make_combat do |selection|
    Keyword.where(id: selection).update_all(combat_relevant: true)
    redirect_to admin_keywords_path
  end

  permit_params :combat_relevant, :name
end
