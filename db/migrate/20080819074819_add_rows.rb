class AddRows < ActiveRecord::Migration
  def self.up
  
    self.down  # truncate tables that aren't empty
    
    Civility.create :name => "Mr"
    Civility.create :name => "Mme"
    Civility.create :name => "Mademoiselle"
    
    FamilySituation.create :name => "Célibataire"
    FamilySituation.create :name => "Marié(e)"
    FamilySituation.create :name => "Veuf/Veuve"
    FamilySituation.create :name => "Divorcé(e)" 
    
    NumberType.create :name => "Mobile"
    NumberType.create :name => "Fixe"
    NumberType.create :name => "Fax"
    NumberType.create :name => "Mobile Professionnel"
    NumberType.create :name => "Fixe Professionnel"
    NumberType.create :name => "Fax Professionnel"
    
    EmployeeState.create :name => "Titulaire"
    EmployeeState.create :name => "Stagiaire"
    EmployeeState.create :name => "Licencié(e)"
    EmployeeState.create :name => "Démissionnaire"
    
    JobContractType.create :name => "CDI"
    JobContractType.create :name => "CDD"
        
    Indicative.create :indicative => "+1", :country => "Etats Unis"
    Indicative.create :indicative => "+33", :country => "France"  
    Indicative.create :indicative => "+34", :country => "Espagne"
    Indicative.create :indicative => "+44", :country => "Royaume Unis"
    Indicative.create :indicative => "+49", :country => "Allemagne"
    Indicative.create :indicative => "+81", :country => "Japon"
    Indicative.create :indicative => "+86", :country => "Chine"
    Indicative.create :indicative => "+262", :country => "Reunion"
    
    dg = Service.create :name => "Direction Générale"
    Service.create :name => "Service Administratif", :service_parent_id => dg.id
    Service.create :name => "Service Commercial", :service_parent_id => dg.id
    prod = Service.create :name => "Production", :service_parent_id => dg.id
    Service.create :name => "Atelier Décor", :service_parent_id => prod.id
    Service.create :name => "Atelier Découpe", :service_parent_id => prod.id
    Service.create :name => "Atelier Fraisage", :service_parent_id => prod.id 
    
    role_admin = Role.create  :name => "admin", :description => "Ce rôle permet d'accéder à toutes les ressources en lecture et en écriture"
    role_guest = Role.create  :name => "guest" ,:description => "Ce rôle permet un accés à toutes les ressources publiques en lecture seule" 
    
    ConfigurationManager.admin_actual_password_policy = 'l0'
    
    user_admin = User.create :username => "admin" ,:password => "admin", :enabled => 1
    user_admin.roles << role_admin
    
    user_guest = User.create :username => "guest" ,:password => "guest", :enabled => 1
    user_guest.roles << role_guest
    
    Menu.find(:all).each do |m|
      MenuPermission.create :list => 1, :view => 1, :add => 1,:edit => 1, :delete => 1, :role_id => role_admin.id, :menu_id => m.id # admin
      MenuPermission.create :list => 1, :view => 1, :add => 0,:edit => 0, :delete => 0, :role_id => role_guest.id, :menu_id => m.id # guest
    end
    
    # put all business objects into the array 'bo'
    bo = []
    Feature.find(:all).each do |f|
      unless f.business_objects.nil?
        f.business_objects.each do |g|
          bo << g unless bo.include?(g)
        end
      end      
    end
    
    bo.each do |m|
      BusinessObjectPermission.create :list => 1, :view => 1, :add => 1,:edit => 1, :delete => 1, :role_id => role_admin.id, :has_permission_type => m # admin
      BusinessObjectPermission.create :list => 1, :view => 1, :add => 0,:edit => 0, :delete => 0, :role_id => role_guest.id, :has_permission_type => m # aall
    end
  end

  def self.down
    [Role,User,Civility,FamilySituation,BusinessObjectPermission,MenuPermission,NumberType,Indicative,JobContractType,Service,EmployeeState].each do |model|
      model.destroy_all
    end
  end
end
