class CreateRecipientMetaOptions < ActiveRecord::Migration
  def self.up
    create_table :recipient_meta_options do |t|
      t.column :project_group_id, :integer
      t.column :parent_id, :integer
      t.column :field, :string
      t.column :value, :string
      t.column :created_on, :datetime
      t.column :updated_on, :timestamp
    end
    
    add_index :recipient_meta_options, [:field, :project_group_id], :unique => true
  end

  def self.down
    drop_table :recipient_meta_options
  end
end
