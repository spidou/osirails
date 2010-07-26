class CreateApproachings < ActiveRecord::Migration
  def self.up
    create_table :approachings do |t|
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :approachings
  end
end
