class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :title
      t.string :color
      t.string :tag_type
      t.integer :launch_id
      t.integer :ordering
    end

    create_table :tags_teams, id: false do |t|
      t.belongs_to :tag, index: true
      t.belongs_to :team, index: true
    end
  end
end
