ActiveAdmin.register Card do

  filter :name
  filter :enabled

  controller do
    def scoped_collection
      super.left_joins(:deck_entries).select("cards.*, count(deck_entries.id) as entry_count").group("cards.id")
    end
  end

  form do |f|
    f.inputs  do
      f.input :name
      f.input :card_type
      f.input :mana_cost
      f.input :cmc
      f.input :power
      f.input :toughness
      f.input :creature_types
      f.input :ability
      f.input :rating
      f.input :loyalty
      f.input :magarena_script
      if f.object.id
        f.input :primary_print_id, as: :select, collection: Hash[f.object.card_prints.with_image.includes(:edition).map { |cp| ["#{cp.edition} #{cp.nr_in_set}", cp.id] }]
      end
    end
    f.inputs do
      f.has_many :card_prints, allow_destroy: false, new_record: false do |cf|
        cf.inputs "Card Print in #{cf.object.edition}" do 
          cf.input :nr_in_set, hint: image_tag(card_image_url(cf.object), width: 200)
        end
      end
    end
    f.actions
  end

  index do
    selectable_column
    column :name do |c|
      link_to c.name, c
    end
    column  :enabled
    column "entry_count", sortable: :entry_count do |c|
      c.entry_count
    end
    column "magarena_rating", sortable: true
    actions
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :name,:card_type,:mana_cost,:cmc,:power,:toughness,:track_prices,:ability,:rating,:loyalty,:magarena_script, :primary_print_id, card_prints_attributes: [:id, :nr_in_set]

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
