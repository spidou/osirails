class CreateSurveySteps < ActiveRecord::Migration
  def self.up
    create_table :survey_steps do |t|
      t.references :commercial_step
      t.string    :status
      t.datetime  :started_at, :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_steps
  end
end
