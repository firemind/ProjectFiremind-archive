ActiveAdmin.register Format do

  filter :name

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name, :enabled, :min_deck_size, :max_deck_size, :max_copies, :description, :auto_queue, restricted_cards_attributes: [:id, :card_name, :limit, :_destroy]
  index do
    selectable_column
    column :name do |format|
      link_to format, format_path(format.name)
    end
    column :min_deck_size
    column :max_deck_size
    column :max_copies
    column :enabled
    column :auto_queue
    column :format_type do |format|
      if format.enabled
        format.format_type
      else
        link_to format.format_type, diff_formats_path(left_id: format.id, right_id: Format.where(format_type: format.format_type, enabled: true).first.id)
      end
    end
    column :editions do |format|
      format.editions.order("release_date desc").first(6).pluck(:short).join("-")
    end
    column :generate_deck do |format|
      link_to format.name, generate_decks_path(format_name: format.name.downcase)
    end
    actions
  end
  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs :name, :enabled, :auto_queue, :min_deck_size, :max_deck_size, :max_copies, :description          # builds an input field for every attribute
    f.inputs do
      f.has_many :restricted_cards, :allow_destroy => true, :new_record => true do |cf|
        cf.input :card_name
        cf.input :limit
      end
    end

    f.actions 
  end

  controller do
    def update(options={}, &block)
      # Workaround for weird bug on form save probably caused by model name Format
      request.formats = [:html]
      super
    end
  end
 
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
