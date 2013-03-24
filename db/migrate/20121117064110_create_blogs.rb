class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
    
    add_index :blogs, [:title]
  end
end
