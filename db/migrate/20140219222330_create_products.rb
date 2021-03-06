class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :serial_number
      t.integer :cost_in_cents
      t.integer :amount_in_stock, default: 0

      t.timestamps null: false
    end
  end
end
