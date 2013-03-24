class RemoveTagsFromBlogs < ActiveRecord::Migration
  def up
    remove_column :blogs, :tags
  end

  def down
    add_column :blogs, :tags, :text
  end
end
