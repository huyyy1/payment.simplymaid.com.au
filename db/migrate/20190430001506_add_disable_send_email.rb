class AddDisableSendEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :unsubscribed, :boolean, default: false
  end
end
