require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Api::V1::Archetypes" do
  api_header
  post "/api/v1/archetypes/classify.json" do
    parameter :format_name, "Format (standard, modern, etc) in which decks have to be legal"
    parameter :decklist, "deck list in text format"

    response_field :archetype, "The best matching archetype"
    response_field :score, "Score of archetype during classification. Number between 0 and 1. The closer to 1 the better the match."

    let(:format_name){ "Modern" }
    let(:decklist){
      <<-TXT
4 Arcbound Ravager
4 Blinkmoth Nexus
4 Cranial Plating
4 Darksteel Citadel
4 Etched Champion
4 Galvanic Blast
4 Glimmervoid
4 Inkmoth Nexus
3 Memnite
1 Mountain
4 Mox Opal
4 Ornithopter
4 Signal Pest
1 Spellskite
4 Springleaf Drum
2 Steel Overseer
4 Vault Skirge
1 Welding Jar
      TXT
    }

    let(:raw_post) { params.to_json }
    example "Classify a known tournament deck" do
      do_request

      expect(headers["Accept"]).to eq("application/json")
      expect(status).to eq(201)

      res =  JSON.parse(response_body)
      expect(res['archetype']['name']).to eq("Test Archetype")
      expect(res['score'].to_f).to eq 0.9
    end
  end
end
