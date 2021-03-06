class TfArchetypeClient
  def initialize
    setup_config
  end

  def setup_config
    @stub = Tensorflow::Serving::PredictionService::Stub.new(Rails.configuration.x.tfserver, :this_channel_is_insecure) #, :this_channel_is_insecure)
  end

  def query(deck_lists)
    recs = []
    deck_lists.each do |dl|
      cards = dl.deck_entries.pluck(:card_id).first(60)
      recs << cards
    end
    res = tfpredict(recs)

    return res.map{|data| {predicted: Archetype.find(data[0]), score: data[1]} }
  end

  protected 

  def tfpredict(recs)

    req = Tensorflow::Serving::ClassificationRequest.new
    #req.model_spec = Tensorflow::Serving::ModelSpec.new name: 'mnist'
    req.model_spec = Tensorflow::Serving::ModelSpec.new name: 'archetype-model', signature_name: "serving_default"
    #input_def = Tensorflow::TensorProto.new(float_val: rec.map(&:to_i), tensor_shape: Tensorflow::TensorShapeProto.new(dim: [Tensorflow::TensorShapeProto::Dim.new(size: 1),Tensorflow::TensorShapeProto::Dim.new(size: rec.size)]), dtype: Tensorflow::DataType::DT_FLOAT)

    #p example
    example_list = Tensorflow::Serving::ExampleList.new

    recs.each do |rec|
      rec = rec.sort.fill(0, rec.size..59)
      list = Tensorflow::Int64List.new(value: rec)
      feature = Tensorflow::Feature.new(int64_list: list)
      #p feature
      features = Tensorflow::Features.new(feature: {"x"=> feature})
      #p features
      example = Tensorflow::Example.new({features: features})
      example_list.examples <<  example 

    end
    #p example_list
    req.input = Tensorflow::Serving::Input.new({example_list: example_list})
    res = @stub.classify req
    res.result['classifications'].map do |r|
      scores= r['classes']
      max = scores.max_by{|r| r.score}
      [max['label'], max.score]
    end
  end

end
