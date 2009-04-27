class FixDates2 < ActiveRecord::Migration
  def self.up
    rename_column :bulletin_layouts, :date_updated, :updated_on
#    rename_column :email_templets, :date_updated, :updated_on
#    rename_column :email_templets, :date_created, :created_on
    rename_column :entries, :date_created, :created_on
    rename_column :entries, :date_updated, :updated_on
    rename_column :projects, :date_updated, :updated_on
    rename_column :sections, :date_created, :created_on
    rename_column :sections, :date_updated, :updated_on
    rename_column :users, :date_created, :created_on
#    rename_column :users, :date_updated, :updated_on
  end

  def self.down
    rename_column :bulletin_layouts, :updated_on, :date_updated
#    rename_column :email_templets, :updated_on, :date_updated
#    rename_column :email_templets, :created_on, :date_created
    rename_column :entries, :created_on, :date_created
    rename_column :entries, :updated_on, :date_updated
    rename_column :projects, :updated_on, :date_updated
    rename_column :sections, :created_on, :date_created
    rename_column :sections, :updated_on, :date_updated
    rename_column :users, :created_on, :date_created
#    rename_column :users, :updated_on, :date_updated
  end
end
