class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.references :country
      t.string :name
    end
  end

  def self.down
    drop_table :regions
  end
end
