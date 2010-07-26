class CreateLegalForms < ActiveRecord::Migration
  def self.up
    create_table :legal_forms do |t|
      t.references :third_type
      t.string :name
      
      t.timestamps
    end        
  end

  def self.down
    drop_table :legal_forms
  end
end
