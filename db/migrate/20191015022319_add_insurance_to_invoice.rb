class AddInsuranceToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :have_insurance, :boolean, default: false
  end
end
