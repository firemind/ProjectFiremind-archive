ActiveAdmin.register DeckList do

  scope("Archetype Missmatch") { |scope| scope.where("human_archetype_id is not null && archetype_id != human_archetype_id") }
  controller do
    def scoped_collection
      super.includes(:formats, archetype: :format, human_archetype: :format).left_joins(:decks).select("deck_lists.*, count(decks.id) as deck_count").group("deck_lists.id")
    end
    def find_resource
      DeckList.where(id: params[:id]).includes(human_archetype: :format, archetype: :format).first!
    end
  end

  filter :human_archetype_name, as: :string
  filter :archetype_name, as: :string
  filter :human_archetype_confirmed
  filter :human_archetype_format_id, as: :check_boxes, collection: proc { Format.enabled }

  index do
    selectable_column
    column :archetype_score
    column "Human Archetype" do |deck_list|
      l = deck_list.human_archetype_confirmed ? "<b>#{deck_list.human_archetype}</b>".html_safe : deck_list.human_archetype.to_s
      link_to l, deck_list.human_archetype, title: deck_list.human_archetype.try(:format)
    end
    column :archetype do |deck_list|
      link_to deck_list.archetype, deck_list.archetype, title: deck_list.archetype.try(:format)
    end
    column :as_text
    column :legal_in do |r|
      r.formats.map(&:name).join(",")
    end
    column :deck_count, sortable: :deck_count do |r|
      r.deck_count
      link_to r.deck_count, admin_decks_path(q: {deck_list_id_eq: r.id})
    end
    actions
  end
  show do
    h3 deck_list.to_s
    attributes_table do
      row :text do
        simple_format deck_list.as_text
      end
      row :formats do
        deck_list.formats.map{|i| "#{i} (#{i.id})"}.join(",")
      end
      row :format_calc_log do
        ul do
          deck_list.format_calc_logs.each do |l|
            li do
              "#{l.formats} #{I18n.l l.created_at}"
            end
          end
        end
      end
    end
  end
  form do |f|
    inputs 'Details' do
      formats = f.object.decks.map(&:format)
      formats = Format.enabled if formats.empty?
      archetypes = Archetype.where(format_id: formats.map(&:id)).includes(:format).order("name")
      li "Classified Archetype #{f.object.archetype} - #{f.object.archetype.try(:format)}"
      if haid= (params[:deck_list] && params[:deck_list][:human_archetype_id])
        f.object.human_archetype_id = haid
      elsif haconf= (params[:deck_list] && params[:deck_list][:human_archetype_confirmed])
        f.object.human_archetype_confirmed =haconf
      end
      input :human_archetype_id, as: :select, collection: Hash[archetypes.map { |archetype| ["#{archetype.name} - #{archetype.format}", archetype.id] }]
      input :human_archetype_confirmed
    end
    panel 'DeckList' do
      div do
        deck = f.object.decks.last
        link_to("Format Calc", format_deck_path(deck, deck.format))if deck
      end
      div do
        f.object.as_text.gsub("\n", "<br>").html_safe
      end
      #render partial: 'deck_lists/decklist', locals:{ deck: f.object}
    end
    actions
  end

  batch_action :archetype_correct do |selection|
    decks = DeckList.find(selection)
    decks.each do |deck|
      deck.human_archetype = deck.archetype
      deck.save(validate: false)
    end
    redirect_to admin_deck_lists_path
  end

  batch_action :confirm_human_archetype do |selection|
    decks = DeckList.find(selection)
    decks.each do |deck|
      deck.human_archetype_confirmed = true
      deck.save(validate: false)
    end
    redirect_to admin_deck_lists_path
  end

  permit_params :human_archetype_id, :human_archetype_confirmed

end
