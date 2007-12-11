class AddLayoutType < ActiveRecord::Migration
  def self.up
    add_column  :templet_layouts, :filter, :string, :limit => 20, :null => true
  end

  def self.down
    remove_column :templet_layouts, :filter
  end
end
