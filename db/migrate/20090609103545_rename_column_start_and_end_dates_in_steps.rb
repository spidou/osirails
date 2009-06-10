class RenameColumnStartAndEndDatesInSteps < ActiveRecord::Migration
  def self.up
    tables = %W{ commercial_steps estimate_steps graphic_conception_steps invoicing_steps survey_steps }
    
    tables.each do |table|
      rename_column table, :start_date, :started_at
      rename_column table, :end_date,   :finished_at
    end
  end

  def self.down
    tables = %W{ commercial_steps estimate_steps graphic_conception_steps invoicing_steps survey_steps }
    
    tables.each do |table|
      rename_column table, :started_at,  :start_date
      rename_column table, :finished_at, :end_date
    end
  end
end
