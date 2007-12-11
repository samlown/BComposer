class AddBulletinRecipientFilter < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :filter_raw, :text, :null => true
  end

  def self.down
    remove_column :bulletins, :filter_raw
  end
end
