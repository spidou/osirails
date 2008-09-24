class CreateStepCommercial < ActiveRecord::Migration
  def self.up
    create_table :step_commercials do |t|
      t.references :order
      t.references :step
      t.string :status
      t.datetime :start_date
      t.datetime :end_date
    end
  end

  def self.down
    drop_table :step_commercials
  end
end
