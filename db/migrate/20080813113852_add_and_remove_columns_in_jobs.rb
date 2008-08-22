class AddAndRemoveColumnsInJobs < ActiveRecord::Migration
  def self.up
    remove_column :jobs, :mission
    remove_column :jobs, :activity
    remove_column :jobs, :goal 
    add_column :jobs, :mission, :text
    add_column :jobs, :activity, :text
    add_column :jobs, :goal, :text 
  end

  def self.down
    remove_column :jobs, :mission
    remove_column :jobs, :activity
    remove_column :jobs, :goal
    add_column :jobs, :mission, :text
    add_column :jobs, :activity, :text
    add_column :jobs, :goal, :text 
    
  end
end
