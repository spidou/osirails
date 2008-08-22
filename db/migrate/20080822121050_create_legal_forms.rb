class CreateLegalForms < ActiveRecord::Migration
  def self.up
    create_table :legal_forms do |t|
      t.string :name
      t.references :third_type

      t.timestamps
    end
    
    LegalForm.create :name => "SARL", :third_type_id => "1"
    LegalForm.create :name => "SA", :third_type_id => "1"
    LegalForm.create :name => "SAS", :third_type_id => "1"
    LegalForm.create :name => "EURL", :third_type_id => "1"
    LegalForm.create :name => "Association", :third_type_id => "1"

    LegalForm.create :name => "Etat", :third_type_id => "2"
    LegalForm.create :name => "Collectivité territoriale", :third_type_id => "2"
        
  end

  def self.down
    drop_table :legal_forms
  end
end
