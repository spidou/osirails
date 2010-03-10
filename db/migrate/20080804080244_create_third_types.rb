class CreateThirdTypes < ActiveRecord::Migration
  def self.up
    create_table :third_types do |t|
      t.string :name
      
      t.timestamps
    end
    
  end

  def self.down
    drop_table :third_types
  end
end
