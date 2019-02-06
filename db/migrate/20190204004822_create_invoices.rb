class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.references :team
      t.references :week
      t.float :earned, default: 0
      t.float :tips, default: 0
      t.float :adjustments, default: 0
      t.float :due, default: 0
      t.float :paid, default: 0
      t.boolean :wages_hourly, default: false
      t.boolean :wages_service_price_only, default: false
      t.float :wages_share, default: 0
      t.float :wages_fee_amount, default: 0
      t.integer :wages_fee_percent, default: 0
      t.integer :hours_earned, default: 0
      t.integer :hours_scheduled, default: 0
      t.boolean :invoice_sent, default: false
      t.timestamps
    end
  end
end
