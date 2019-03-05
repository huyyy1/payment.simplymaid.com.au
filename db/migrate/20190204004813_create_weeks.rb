class CreateWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :weeks do |t|
      t.date :start_date
      t.date :end_date
      t.date :payment_date
      t.float :payment_total, default: 0
      t.boolean :is_busy, default: false
      t.datetime :busy_from
      t.boolean :is_parsed, default: false
      t.datetime :parsed_at
      t.boolean :is_processed, default: false
      t.datetime :processed_at
      t.text :aba_file_gst
      t.text :aba_file_no_gst
      t.datetime :aba_created_at
    end
  end
end
