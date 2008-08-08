class CreatePremiums < ActiveRecord::Migration
  def self.up
    create_table :premiums do |t|     
      t.integer :prime
      t.date :date
      t.text :remark
      t.references :employee
      
      t.timestamps
    end
  end

  def self.down
    drop_table :premiums
  end
end
