class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.references :country, :region
      t.string :name, :zip_code
    end
  end

  def self.down
    drop_table :cities
  end
end
