class AddNeedsGroovyToCards < ActiveRecord::Migration
  def change
    add_column :cards, :needs_groovy, :boolean, default: false, null: false
  end
end
