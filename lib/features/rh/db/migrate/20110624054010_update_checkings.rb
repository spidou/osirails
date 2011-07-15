class UpdateCheckings < ActiveRecord::Migration
  def self.up
    change_table :checkings do |t|
      # Suppression des champs des anciens champs de la table Checking
      t.remove :user_id ,:absence_hours, :absence_minutes, :overtime_hours
      t.remove :overtime_minutes, :overtime_comment, :cancelled      
      # Ajout d'un champs pour stocker la période de l'absence de type string
      t.string :absence_period
      # Ajout des champs de type datetime pour stocker les horaires de pointage
      t.datetime :morning_start ,:morning_end, :afternoon_start, :afternoon_end
      # Ajout des champs de type texte pour stocker les commentaires liès aux irrégularités
      t.text :morning_start_comment, :morning_end_comment, :afternoon_start_comment, :afternoon_end_comment
    end 
  end

  def self.down
    # Destruction des champs de la nouvelle table Checking
    remove_column :checkings , :morning_start 
    remove_column :checkings , :morning_end
    remove_column :checkings , :afternoon_start
    remove_column :checkings , :afternoon_end
    remove_column :checkings , :morning_start_comment
    remove_column :checkings , :morning_end_comment
    remove_column :checkings , :afternoon_start_comment
    remove_column :checkings , :afternoon_end_comment
    remove_column :checkings , :absence_period

    # Rétablissement de l'ensemble des champs de l'ancien schéma 
    add_column :checkings ,  :user , :references
    add_column :checkings , :absence_hours , :integer
    add_column :checkings , :absence_minutes , :integer
    add_column :checkings , :overtime_hours , :integer
    add_column :checkings , :overtime_minutes , :integer
    add_column :checkings , :overtime_comment , :text
    add_column :checkings , :cancelled , :boolean
  end
end
