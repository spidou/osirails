class UpdateDeliveryStepsChangeParentStep < ActiveRecord::Migration
  def self.up
    rename_column :delivery_steps, :production_step_id, :delivering_step_id
  end

  def self.down
    rename_column :delivery_steps, :delivering_step_id, :production_step_id
  end
end
