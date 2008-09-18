class CreateMissingElements < ActiveRecord::Migration
  def self.up
    create_table :missing_elements do |t|
      t.string :name
      t.string :description
      t.references :orders_steps
      
      t.timestamps
    end
  end

  def self.down
    drop_table :missing_elements
  end
end
