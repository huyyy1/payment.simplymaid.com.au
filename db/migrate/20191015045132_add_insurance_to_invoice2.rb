class AddInsuranceToInvoice2 < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :have_insurance_override, :boolean, default: false
  end
end
