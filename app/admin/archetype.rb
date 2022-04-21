ActiveAdmin.register Archetype do

  filter :name
  filter :format
  filter :has_banner

  controller do
    def scoped_collection
      super.includes(:format, thumb_print: :edition).joins("LEFT JOIN `deck_lists` ON `deck_lists`.`human_archetype_id` = `archetypes`.`id`").group("archetypes.id").select 'archetypes.*, count(deck_lists.id) as dlcount'
    end
  end

  filter :format_id, as: :check_boxes, collection: proc { Format.enabled }

  sidebar :help do
    link_to "Confirmables", archetype_confirmation_index_path  
  end

  index do
    selectable_column
    column   :avatar do |archetype|
      image_tag archetype_avatar_path(archetype), width: 50
    end
    column   :name
    column   :format
    column   :hdl_count, sortable: "dlcount" do |archetype|
      link_to archetype.dlcount, admin_deck_lists_path(q: {human_archetype_name_contains: archetype.to_s, human_archetype_format_id_in: [archetype.format_id]})
    end
    column   :dl_count do |archetype|
      link_to archetype.deck_lists.count, admin_deck_lists_path(q: {archetype_name_contains: archetype.to_s, archetype_format_id_in: [archetype.format_id]})
    end
    column   :has_banner
    column   :compare_to do |archetype|
      link_to "compare to", compare_select_archetype_path(archetype)
    end
    column   :id
    actions
  end

  form do |f|
    f.inputs  do
      f.input :name
      f.input :format, collection: Format.order("enabled desc")
      if f.object.id
        f.input :thumb_print_id, as: :select, collection: Hash[f.object.cards.select("distinct(cards.id), cards.name").includes(:card_prints).map{|c| c.card_prints.joins(:edition).with_thumb.select("card_prints.id, editions.short as short").map { |cp| ["#{c.name} #{cp.short}", cp.id] }}.flatten(1)]
      end
    end
    f.inputs do
      f.has_many :archetype_aliases, :allow_destroy => true, :new_record => true do |cf|
        cf.input :name
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
    render 'archetype_aliases'
  end

  batch_action :create_deck_variations do |selection|
    sysuser = User.get_sys_user
    Archetype.find(selection).each do |archetype|
      archetype.human_deck_lists.each do |dl|
        DeckList.transaction do
          cout = dl.deck_entries.where("amount > 1").sample
          cin = dl.deck_entries.where("amount < 4").where.not(card_id: cout.card.id).sample
          next unless cin
          new_deck = Deck.new
          new_deck.title = "#{archetype} v"
          new_deck.author = sysuser
          new_deck.format = archetype.format
          dl_text = dl.as_text
          dl_text.gsub!("#{cout.amount} #{cout.card}", "#{cout.amount-1} #{cout.card}")
          dl_text.gsub!("#{cin.amount} #{cin.card}", "#{cin.amount+1} #{cin.card}")
          new_deck.decklist = dl_text
          new_deck.public = false
          new_deck.description = "Automatically generated variation for archetype #{archetype}"
          new_deck.auto_generated = true
          new_deck.save!
          ndl = new_deck.deck_list
          FormatCalcWorker.new.perform(ndl.id)
          ndl.human_archetype_id = dl.human_archetype_id
          ndl.save!
          AssignArchetypeWorker.perform_async ndl.id
        end
      end
    end
    redirect_to admin_archetypes_path
  end

  permit_params :name, :format_id, :thumb_print_id, archetype_aliases_attributes: [:id, :name, :_destroy]

end
