class AddFbColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_user_id, :integer,:limit => 8
  end
end
