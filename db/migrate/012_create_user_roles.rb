class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table "user_roles" do |t|
      t.column "user_id",         :integer,                      :null => false
      t.column "project_id",      :integer,                      :null => false
      t.column "edit_project",    :boolean,   :default => false, :null => false
      t.column "create_bulletin", :boolean,   :default => false, :null => false
      t.column "send_bulletin",   :boolean,   :default => false, :null => false
      t.column "edit_bulletin",   :boolean,   :default => false, :null => false
      t.column "edit_recipients", :boolean,   :default => false, :null => false
      t.column "edit_section",    :boolean,   :default => false, :null => false
      t.column "edit_entry",      :boolean,   :default => false, :null => false
      t.column "edit_templates",  :boolean,   :default => false, :null => false
      t.column "created_on",      :datetime,                     :null => false
      t.column "updated_on",      :timestamp
    end
  end

  def self.down
    drop_table :user_roles
  end
end
