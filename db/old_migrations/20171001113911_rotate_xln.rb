class RotateXln < ActiveRecord::Migration[5.1]
  def change
    return if Rails.env.test?
		new_set_short = "XLN"
		FormatUpdater.perform(
			br_updates: {
				vintage: {
					restricted: {
						additions: [
							"Thorn of Amethyst",
							"Monastery Mentor"
						],
						removals: [
              "Yawgmoth's Bargain"
						]
					}
				}
			},
			set_changes: {
				standard: {
					added: [new_set_short],
          removed: %w(BFZ OGW SOI EMN)
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
