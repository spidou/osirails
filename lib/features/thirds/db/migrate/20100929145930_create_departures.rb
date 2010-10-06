class CreateDepartures < ActiveRecord::Migration
  def self.up
    create_table :departures do |t|
      t.references  :forwarder
      t.string      :city_name, :region_name, :country_name
      t.boolean     :hidden
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :departures
  end
end
