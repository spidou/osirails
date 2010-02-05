class CreateDunnings < ActiveRecord::Migration
  def self.up
    create_table :dunnings do |t|
      t.references :has_dunning, :creator, :dunning_sending_method, :cancelled_by
      t.string     :has_dunning_type
      t.date       :date
      t.text       :comment
      t.boolean    :cancelled
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dunnings
  end
end
