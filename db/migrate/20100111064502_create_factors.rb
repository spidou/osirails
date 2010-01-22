class CreateFactors < ActiveRecord::Migration
  def self.up
    create_table :factors do |t|
      t.string :name, :fullname
      
      t.timestamps
    end
  end

  def self.down
  end
end
