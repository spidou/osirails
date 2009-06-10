class RenameAllStepTables < ActiveRecord::Migration
  def self.up
    rename_table :step_commercials, :commercial_steps
    
    rename_table :step_surveys, :survey_steps
    rename_column :survey_steps, :step_commercial_id, :commercial_step_id
    
    rename_table :step_graphic_conceptions, :graphic_conception_steps
    rename_column :graphic_conception_steps, :step_commercial_id, :commercial_step_id
    
    rename_table :step_estimates, :estimate_steps
    rename_column :estimate_steps, :step_commercial_id, :commercial_step_id
    rename_column :quotes, :step_estimate_id, :estimate_step_id
    
    rename_table :step_invoicings, :invoicing_steps
  end

  def self.down
    rename_table :commercial_steps, :step_commercials
    
    rename_table :survey_steps, :step_surveys
    rename_column :step_surveys, :commercial_step_id, :step_commercial_id
    
    rename_table :graphic_conception_steps, :step_graphic_conceptions
    rename_column :step_graphic_conceptions, :commercial_step_id, :step_commercial_id
    
    rename_table :estimate_steps, :step_estimates
    rename_column :step_estimates, :commercial_step_id, :step_commercial_id
    rename_column :quotes, :estimate_step_id, :step_estimate_id
    
    rename_table :invoicing_steps, :step_invoicings
  end
end
