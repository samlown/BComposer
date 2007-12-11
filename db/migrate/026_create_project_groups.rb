class CreateProjectGroups < ActiveRecord::Migration
  def self.up
    create_table :project_groups do |t|
      t.column :name, :string, :null => false
      t.column :created_on, :datetime
    end
    
    # insert default entry
    pg = ProjectGroup.new( :name => 'Default' )
    pg.save
    
    add_column :recipients, :project_group_id, :integer, :default => pg.id
    add_column :projects, :project_group_id, :integer, :default => pg.id
  end

  def self.down
    drop_table :project_groups
    remove_column :recipients, :project_group_id
    remove_column :projects, :project_group_id
  end
end
