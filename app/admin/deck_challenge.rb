ActiveAdmin.register DeckChallenge do

  filter :text

  form do |f|
    f.inputs  do
      f.input :featured
    end
    f.actions
  end
  permit_params :featured

end
