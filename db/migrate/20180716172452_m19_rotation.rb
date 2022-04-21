class M19Rotation < ActiveRecord::Migration[5.1]
  def change
    return if Rails.env.test?
      new_set_short = "M19"
      FormatUpdater.perform(
        br_updates: {
          legacy: {
            banned: {
              additions: [
                "Deathrite Shaman",
                "Gitaxian Probe"
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
            added: [new_set_short, "BBD", "GS1"]
          },
          pauper: {
            added: [new_set_short, "BBD", "GS1"]
          },
          vintage: {
            added: [new_set_short, "BBD", "GS1"]
          }
        }
      )
  end
end
