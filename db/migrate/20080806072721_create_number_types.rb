class CreateNumberTypes < ActiveRecord::Migration
  def self.up
    create_table :number_types do |t|     
      t.string :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :number_types
  end
end
