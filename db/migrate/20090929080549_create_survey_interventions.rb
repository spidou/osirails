class CreateSurveyInterventions < ActiveRecord::Migration
  def self.up
    create_table :survey_interventions do |t|
      t.references :internal_actor
      t.datetime :start_date
      t.integer  :duration_hours, :duration_minutes
      
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_interventions
  end
end
