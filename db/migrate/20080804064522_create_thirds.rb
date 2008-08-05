class CreateThirds < ActiveRecord::Migration
  def self.up
    create_table :thirds do |t|
      # TODO Mettre en commentaires les colonnes qui appartiennent a chaque type
      t.string :name
      t.string :legal_form
      t.string :siret_number
      t.references :activity_sector
      t.string :activities
      t.integer :note, :default => 0
      t.string :banking_informations
      t.string :type
      t.references :third_type
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :thirds
  end
end