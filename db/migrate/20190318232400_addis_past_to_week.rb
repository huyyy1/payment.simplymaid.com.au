class AddisPastToWeek < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :is_past, :boolean, default: false
  end
end
