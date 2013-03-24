class RemoveUseridFromBlog < ActiveRecord::Migration
  def up
    remove_column :blogs, :user_id
  end

  def down
    add_column :blogs, :user_id, :integer
  end
end
