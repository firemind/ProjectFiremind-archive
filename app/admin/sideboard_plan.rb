ActiveAdmin.register SideboardPlan do

  filter :created_at

  controller do
    def scoped_collection
      super.includes(:archetype, deck: :author)
    end
  end


  index do
    selectable_column
    id_column
    column :author do |r|
      link_to r.deck.author, r.deck.author
    end
    column :deck do |r|
      link_to r.deck, r.deck
    end
    column :archetype
    column :created_at
    actions
  end
end


