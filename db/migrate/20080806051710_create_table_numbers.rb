class CreateTableNumbers < ActiveRecord::Migration
  def self.up
    create_table :numbers do |t|     
      t.string :number
      t.references :indicative
      t.references :number_type
      t.references :has_number , :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :numbers
  end
end
