class EldritchMoonRotation < ActiveRecord::Migration
  def change
    return if Rails.env.test?
      FormatUpdater.perform(
        set_changes: {
          standard: {
            added: ["EMN"]
          },
          modern: {
            added: ["EMN"]
          },
          legacy: {
            added: ["EMN"]
          },
          pauper: {
            added: ["EMN"]
          },
          vintage: {
            added: ["EMN"]
          }
        }
      )
  end
end
