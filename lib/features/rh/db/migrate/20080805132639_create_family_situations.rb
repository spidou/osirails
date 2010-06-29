class CreateFamilySituations < ActiveRecord::Migration
  def self.up
    create_table :family_situations do |t|     
      t.string :name
    end
  end

  def self.down
    drop_table :family_situations
  end
end
