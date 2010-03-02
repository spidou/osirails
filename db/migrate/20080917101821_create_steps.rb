class CreateSteps < ActiveRecord::Migration
  def self.up
    create_table :steps do |t|
      t.references :parent
      t.string  :name, :title, :description
      t.integer :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :steps
  end
end
