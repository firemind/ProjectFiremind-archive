class GrnRotation < ActiveRecord::Migration[5.1]
  def change
      return if Rails.env.test?
      new_set_short = "GRN"
      FormatUpdater.perform(
        set_changes: {
          standard: {
            added: [new_set_short],
            removed: ['KLD', 'AER', 'AKH', 'HOU']
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
