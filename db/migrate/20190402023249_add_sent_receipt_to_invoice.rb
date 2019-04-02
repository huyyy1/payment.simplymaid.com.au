class AddSentReceiptToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :due_receipt_sent, :boolean, default: false
    add_column :invoices, :due_receipt_sent_at, :datetime, default: nil
    add_column :invoices, :paid_receipt_sent, :boolean, default: false
    add_column :invoices, :paid_receipt_sent_at, :datetime, default: nil
  end
end
