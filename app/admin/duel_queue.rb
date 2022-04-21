ActiveAdmin.register DuelQueue do

  scope("Internal") { |scope| scope.internal }

  controller do
    def scoped_collection
      super.includes :user
    end
  end
  
  filter :name
  filter :active

  index do
    selectable_column
    column :user
    column :name
    column :magarena_version
    column "ai config" do |dq|
      "#{dq.ai1}#{dq.ai1_strength} vs #{dq.ai2}#{dq.ai2_strength}"
    end
    column "duel count" do |dq|
      "#{dq.duels.finished.size} / #{dq.duels.size}"
    end
    column "last_duel" do |dq|
      if ld = dq.duels.last
        link_to "duel #{ld.updated_at}", ld
      end
    end
    column :active
    column :created_at
    actions
  end

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
 permit_params do
   permitted = [:name, :ai1, :ai2, :ai1_strength, :ai2_strength, :magarena_version_major, :magarena_version_minor, :life, :active, :custom_params]
   permitted
 end


end
