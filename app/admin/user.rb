ActiveAdmin.register User do

  filter :name
  filter :email

  index do
    actions
    column :name
    column :email
    column :sign_in_count
    column :current_sign_in_at
    column :created_at
    column :provider
    column :access_token
    column :sysuser
    column :airm_admin
    column :may_add_unimplementable_reasons

  end


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :sysuser, :access_token, :airm_admin, :may_add_unimplementable_reasons
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
