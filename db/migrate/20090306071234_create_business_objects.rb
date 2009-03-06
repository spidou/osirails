class CreateBusinessObjects < ActiveRecord::Migration
  def self.up
    create_table :business_objects do |t|
      t.string :name, :unique => true
    end
  end

  def self.down
    drop_table :business_objects
  end
end
