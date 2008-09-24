class CreateStepGraphicConceptions < ActiveRecord::Migration
  def self.up
    create_table :step_graphic_conceptions do |t|
      t.references :step_commercial
      t.string :status
      t.datetime :start_date
      t.datetime :end_date
    end
  end

  def self.down
    drop_table :step_graphic_conceptions
  end
end
