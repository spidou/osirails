class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.string :name
      t.string :zip_code
      t.references :country
    end
    
    ### Add cities from the sql file
    # mysql -p -u {username} osirails_development < {/path/to/project}/db/cities.sql
  end

  def self.down
    drop_table :cities
  end
end
