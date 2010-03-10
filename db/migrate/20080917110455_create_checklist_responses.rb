class CreateChecklistResponses < ActiveRecord::Migration
  def self.up
    create_table :checklist_responses do |t|
      t.references :checklist_option, :product
      t.text :answer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_responses
  end
end
