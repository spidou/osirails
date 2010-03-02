class CreateCivilities < ActiveRecord::Migration
  def self.up
    create_table :civilities do |t|     
      t.string :name
    end
  end

  def self.down
    drop_table :civilities
  end
end
