class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.text :description
      
      t.timestamps
    end
    # TODO add rows while migrate
    # Role.create( :name => 'Admin' , :description =>'Compte Administrateur présent par défault')
    # Role.create( :name => 'Tout le monde', :description =>'Compte regroupant tous les utilisateurs')
  end

  def self.down
    drop_table :roles
  end
end
