ActiveAdmin.register Misclassification do
  filter :created_at
  controller do
    def scoped_collection
      super.includes :deck_list, expected: :format, predicted: :format
    end
  end
  index do
    actions
    column :expected do |r|
      "#{r.expected} (#{r.expected.format})"
    end
    column :predicted do |r|
      "#{r.predicted} (#{r.predicted.format})"
    end
    column :deck_list do |r|
      if r.deck_list
        link_to r.deck_list, r.deck_list
      end
    end
    column :created_at
    column :link do |r|
      link_to "Compare", compare_archetypes_path(left_id: r.expected_id, right_id: r.predicted_id)
    end
  end

end
