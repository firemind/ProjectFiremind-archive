class AddKeywordsCardsMap < ActiveRecord::Migration[5.1]
  def change
    create_table :cards_keywords, id: false do |t|
      t.belongs_to :card, index: true
      t.belongs_to :keyword, index: true
    end
    add_index :cards_keywords, [:card_id, :keyword_id], unique: true

  end
end
