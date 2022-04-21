ActiveAdmin.register_page "Misclassification Dashboard" do
  content do
    columns do
      Misclassification.group("expected_id, predicted_id").select("expected_id, predicted_id, count(id) as cnt").limit(20).includes(expected: :format, predicted: :format).order("cnt desc").each do |mc|
        column min_width: "250px" do
          h4 do
            span do
              link_to mc.expected, mc.expected
            end
            span do
              " != "
            end
            span do
              link_to mc.predicted, mc.predicted
            end
          end
          ul do
            li do
              "Count: #{mc.cnt}"
            end
            li do
              if mc.expected.format != mc.predicted.format
                "Formats: #{mc.expected.format} - #{mc.predicted.format}"
              else
                "Format: #{mc.expected.format}"
              end
            end
            Misclassification.where(expected_id: mc.expected_id, predicted_id: mc.predicted_id).select("distinct(deck_list_id)").includes(:deck_list).each do |r|
              li do
                link_to "Deck List #{r.deck_list_id}", r.deck_list
              end
            end
          end
          span do
            link_to "Compare", compare_archetypes_path(left_id: mc.expected_id, right_id: mc.predicted_id), class:"button"
          end
        end
      end
    end
  end

end
