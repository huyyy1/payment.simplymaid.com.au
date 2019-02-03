class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :email
      t.boolean :is_gst, default: false
      t.string :abn, length: 20
      t.string :billing_name
      t.string :address
      t.string :bsb, length: 6
      t.string :account_number, length: 20
      t.text :notes
      t.timestamps
    end
  end
end
