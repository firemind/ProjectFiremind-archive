ActiveAdmin.register CardPrint do
  filter :track_prices
  scope("With Thumb") { |scope| scope.where(has_thumb: true) }

  index do
    actions
    column   :thumb do |cp|
      if cp.has_thumb
        image_tag "#{THUMB_SERVER_URL}#{cp.edition.short}/#{cp.nr_in_set}.jpg", width: 50
      end
    end
    column :card
    column :edition
    column :track_prices
    column :has_crop
  end


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :track_prices
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
