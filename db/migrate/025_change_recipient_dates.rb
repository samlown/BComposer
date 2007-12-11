class ChangeRecipientDates < ActiveRecord::Migration
  def self.up
    add_column :recipients, :new_data, :text, :null => true
    rename_column :recipients, :date_created, :created_on
    rename_column :recipients, :date_updated, :updated_on
  end

  def self.down
    remove_column :recipients, :new_data
    rename_column :recipients, :created_on, :date_created
    rename_column :recipients, :updated_on, :date_updated
  end
end
