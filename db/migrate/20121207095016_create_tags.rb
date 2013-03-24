class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :blog_id
      t.string :tag, :unique=>true

      t.timestamps
    end
    add_index :tags, [:tag]
  end
end
