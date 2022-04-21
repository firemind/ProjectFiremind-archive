class AkhRotation < ActiveRecord::Migration[5.0]
  def change
    return if Rails.env.test?
		new_set_short = "AKH"
		FormatUpdater.perform(
			br_updates: {
				vintage: {
					restricted: {
						additions: [
							"Gitaxian Probe",
							"Gush"
						]
					}
				},
				legacy: {
					banned: {
						additions: [
							"Sensei's Divining Top"
						]
					}
				},
				standard: {
					banned: {
						additions: [
							"Felidar Guardian"
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
