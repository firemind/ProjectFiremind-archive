class RixRotation < ActiveRecord::Migration[5.1]
  def change
    return if Rails.env.test?
		new_set_short = "RIX"
		FormatUpdater.perform(
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
			},
			set_changes: {
				standard: {
					added: [new_set_short]
				},
				modern: {
					added: [new_set_short]
				},
				legacy: {
					added: [new_set_short]
				},
				pauper: {
					added: [new_set_short]
				},
				vintage: {
					added: [new_set_short]
				}
			}
		)


  end
end
