class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
       t.column :name, :string
       t.column :password_hash, :string
       t.column :description, :text
       t.column :admin_role, :boolean, :default => 0
       t.column :date_created, :datetime
       t.column :date_update, :timestamp
    end
    
  end

  def self.down
    drop_table :users
  end
end
