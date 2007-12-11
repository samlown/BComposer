class AddUserRoles < ActiveRecord::Migration
  def self.up
    add_column :user_roles, "edit_pages",  :boolean,   :default => false, :null => false
    add_column :user_roles, "edit_files",  :boolean,   :default => false, :null => false
  end
  
  def self.down
    remove_column :user_roles, "edit_pages"
    remove_column :user_roles, "edit_files"
  end
end
