class AddInsuranceToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :have_insurance, :boolean, default: false
  end
end
