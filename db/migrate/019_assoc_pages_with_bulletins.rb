class AssocPagesWithBulletins < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :bulletin_id, :integer
    remove_column :content_pages, :project_id
  end

  def self.down
    raise IrreversibleMigration
  end
end
