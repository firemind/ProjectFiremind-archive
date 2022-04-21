ActiveAdmin.register RestrictedCard do

  form do |f|
    f.inputs 'restricted' do
      f.input :card_id, as: :select, collection: Card.select(:name)
      f.input :format_id, as: :select, collection: Format.select(:name)
      f.input :limit
    end
  end
end
