class AddBulletinStatsData < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :stats_data, :text
  end

  def self.down
    remove_column :bulletins, :stats_data
  end
end
