class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
       t.string :name
    end
  
    Country.create :name => "FRANCE"
    Country.create :name => "REUNION"
    Country.create :name => "ESPAGNE"
    
  end

  def self.down
    drop_table :countries
  end
end
