class AddRecipientRealConfirm < ActiveRecord::Migration
  def self.up
    add_column :recipients, :confirmed_real, :boolean, :default => 0
  end

  def self.down
    remove_columne :recipients, :confirmed_real
  end
end
