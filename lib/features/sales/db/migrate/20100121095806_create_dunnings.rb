class CreateDunnings < ActiveRecord::Migration
  def self.up
    create_table :dunnings do |t|
      t.references :creator, :dunning_sending_method, :cancelled_by
      t.references :has_dunning, :polymorphic => true
      t.date       :date
      t.text       :comment
      t.datetime   :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dunnings
  end
end
