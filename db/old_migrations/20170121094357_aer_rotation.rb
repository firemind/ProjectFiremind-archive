class AerRotation < ActiveRecord::Migration[5.0]
  def change
      return if Rails.env.test?

      FormatUpdater.perform(
        br_updates: {
          modern: {
            banned: {
              additions: [
                "Gitaxian Probe",
                "Golgari Grave-Troll"
              ]
            }
          },
          standard: {
            banned: {
              additions: [
                "Emrakul, the Promised End",
                "Smuggler's Copter",
                "Reflector Mage"
              ]
            }
          }
        },
        set_changes: {
          standard: {
            added: ["AER"]
          },
          modern: {
            added: ["AER"]
          },
          legacy: {
            added: ["AER"]
          },
          pauper: {
            added: ["AER"]
          },
          vintage: {
            added: ["AER"]
          }
        }
      )
  end
end
