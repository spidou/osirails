class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.references :service
      t.string  :name
      t.boolean :responsible, :default => false
      t.text    :mission, :activity, :goal
      
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
