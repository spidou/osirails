class CreateEstablishments < ActiveRecord::Migration
  def self.up
    create_table :establishments do |t|
      t.references :establishment_type, :customer
      t.string     :name
      t.boolean    :activated, :default => true
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :establishments
  end
end
