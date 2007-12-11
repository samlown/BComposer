class RemoveOldRecipientFields < ActiveRecord::Migration
  def self.up
    remove_column :recipients, :project_id
    remove_column :recipients, :state
    remove_column :recipients, :confirm_code
    remove_column :recipients, :pass
  end

  def self.down
    raise IrreversibleMigration
  end
end
