class CreateDiscardTypes < ActiveRecord::Migration
  def self.up
    create_table :discard_types do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :discard_types
  end
end
