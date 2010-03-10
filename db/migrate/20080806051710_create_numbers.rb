class CreateNumbers < ActiveRecord::Migration
  def self.up
    create_table :numbers do |t|
      t.references :has_number , :polymorphic => true
      t.references :indicative, :number_type
      t.string  :number
      t.boolean :visible, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :numbers
  end
end
