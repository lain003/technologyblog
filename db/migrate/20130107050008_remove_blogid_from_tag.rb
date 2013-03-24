class RemoveBlogidFromTag < ActiveRecord::Migration
  def up
    remove_column :tags, :blog_id
  end

  def down
    add_column :tags, :blog_id, :integer
  end
end
