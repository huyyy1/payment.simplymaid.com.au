class CreateWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :weeks do |t|
      t.date :start_date
      t.date :end_date
      t.date :payment_date
      t.boolean :is_parsed, default: false
      t.boolean :is_processed, default: false
      t.datetime :processed_at
      t.datetime :parsed_at
    end
  end
end
