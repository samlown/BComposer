class FixDates < ActiveRecord::Migration
  def self.up
    rename_column :tags, :create_on, :created_on
    rename_column :templets, :date_created, :created_on
    rename_column :templets, :date_updated, :updated_on
    rename_column :templet_layouts, :date_created, :created_on
    rename_column :templet_layouts, :date_updated, :updated_on
  end

  def self.down
    rename_column :tags, :created_on, :create_on
    rename_column :templets, :created_on, :date_created 
    rename_column :templets, :updated_on, :date_updated
    rename_column :templet_layouts, :created_on, :date_created
    rename_column :templet_layouts, :updated_on, :date_updated
  end
end
