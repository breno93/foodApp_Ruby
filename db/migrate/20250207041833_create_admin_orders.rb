class CreateAdminOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :customer_email
      t.boolean :fullfiled
      t.integer :total
      t.string :addres

      t.timestamps
    end
  end
end
