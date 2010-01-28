class CreateDunnings < ActiveRecord::Migration
  def self.up
    create_table :dunnings do |t|
      t.date       :date
      t.text       :comment
      t.string     :has_dunning_type
      t.boolean    :cancelled
      t.references :creator, :dunning_sending_method, :has_dunning, :cancelled_by
      t.timestamps
    end
  end

  def self.down
    drop_table :dunnings
  end
end
