class CreateIndicatives < ActiveRecord::Migration
  def self.up
    create_table :indicatives do |t|
      t.references :country
      t.string :indicative
      
      t.timestamps
    end
  end

  def self.down
    drop_table :indicatives
  end
end
