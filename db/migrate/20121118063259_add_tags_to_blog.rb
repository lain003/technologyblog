class AddTagsToBlog < ActiveRecord::Migration
  def change
    add_column :blogs, :tags, :text
  end
end
