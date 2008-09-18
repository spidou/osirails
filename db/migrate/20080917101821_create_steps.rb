class CreateSteps < ActiveRecord::Migration
  def self.up
    create_table :steps do |t|
      t.string :name
      t.string :title
      t.integer :parent_id
      t.string :description
      t.integer :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :steps
  end
end
