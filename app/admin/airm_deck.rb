ActiveAdmin.register AirmDeck do

  controller do
    def scoped_collection
      super.includes deck_list1: :archetype, deck_list2: :archetype
    end
  end

  index do
    column :deck_list1
    column :deck_list2
    column :rounds
    column :user
    actions
  end

  filter :rounds

  permit_params :deck_list1_id, :deck_list2_id, :rounds
end
