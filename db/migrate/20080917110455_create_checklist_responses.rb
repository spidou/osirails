class CreateChecklistResponses < ActiveRecord::Migration
  def self.up
    create_table :checklist_responses do |t|
      t.references :orders_steps
      t.references :checklist
      t.references :has_checklist_response, :polymorphic => true
      t.string :answer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_responses
  end
end
