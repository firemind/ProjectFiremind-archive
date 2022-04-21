class BrUpdate201802 < ActiveRecord::Migration[5.1]
  def change
    add_index :deck_entries, [:card_id, :amount]
    return if Rails.env.test?

		FormatUpdater.perform(
      br_name: "February 2018",
			br_updates: {
				standard: {
					banned: {
						additions: [
							"Attune with Aether",
              "Rogue Refiner",
              "Rampaging Ferocidon",
              "Ramunap Ruins",
						]
					}
				},
				modern: {
					banned: {
						removals: [
							"Bloodbraid Elf",
              "Jace, the Mind Sculptor",
						]
					}
				}
			}
    )
  end
end
