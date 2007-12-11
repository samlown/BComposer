class ModifyButtinsDates < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :date, :date
    rename_column :bulletins, :date_updated, :updated_on
  end

  def self.down
    rename_column :bulletins, :updated_on, :date_updated
    remove_column :bulletins, :date
  end
end
