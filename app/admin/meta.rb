ActiveAdmin.register Meta do

  filter :name

  form do |f|
    f.inputs  do
      f.input :name
      f.input :format
      f.input :user, collection: Hash[User.all.map { |user| ["#{user.name} #{user.email}", user.id] }]
    end
    f.inputs do
      f.has_many :meta_fragments, :allow_destroy => true, :new_record => true do |cf|
        cf.input :occurances
        cf.input :archetype, collection: Archetype.where(format_id: f.object.format_id).order("name")
      end
    end
    f.actions
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name, :format_id, :user_id, meta_fragments_attributes: [:id, :occurances, :archetype_id, :_destroy]
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  batch_action :update_from_mtggf do |selection|
    require 'mtggf_client'
    client = MtggfClient.new
    Meta.find(selection).each do |meta|
      client.update_meta(meta.format.name.downcase, meta)
    end
  end

end
