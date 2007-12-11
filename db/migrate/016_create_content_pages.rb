class CreateContentPages < ActiveRecord::Migration
  def self.up
    create_table :content_pages do |t|
      t.column :project_id, :integer, :null => false
      t.column :templet_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :status, :string, :null => false, :default => 'O', :limit => 1
      t.column :abstract, :text
      t.column :content, :text
      t.column :notes, :text
      t.column :created_on, :datetime, :null => false
      t.column :updated_on, :timestamp, :null => false
    end
  end

  def self.down
    drop_table :content_pages
  end
end
