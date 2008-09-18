module FeaturesHelper
  
  # Helper method to display the good control button for the gestion of installation/uninstallation of a feature
  def display_install_button(feature)
    if feature.installed? and !feature.activated?
      button = button_to("Désinstaller", {:action => "show", :id => feature.id}, :method => :get)
    elsif !feature.installed? 
      button = button_to("Installer", {:action => "install", :id => feature.id}, :confirm => 'Voulez-vous installer ?', :method => :put) 
    end 
    button 
  end    
 
  
  # Helper method to display the good control button for the gestion of activation/deactivation of a feature
  def display_activate_button(feature)
    if feature.activated?
      button = button_to("Desactiver", {:action => "disable", :id => feature.id}, :confirm => 'Voulez-vous desactiver ?', :method => :put) 
    elsif feature.installed? 
      button = button_to("Activer", {:action => "enable", :id => feature.id}, :confirm => 'Voulez-vous activer ?', :method => :put)
    end
    button    
  end
  
  # Helper method to display the good link for the gestion of installation/uninstallation of a feature
  def display_install_link(feature)
    if feature.base_feature? 
        button= "<a class=\"admin_features_activated-installed\" href=\" \" title='Vous ne pouvez pas désinstaller le module "+feature.name+" car il appartient au noyau  !' Onclick=\"alert ('Vous ne devez pas désinstaller le module "+feature.name+" car il appartient au noyau  ! ');return false\" >Oui</a>" if feature.installed?
    elsif feature.activated?
      # button = link_to("<div class=\"admin_features_activated-installed\">Oui</div>", {:action => "index", :id => feature.id}, :title=>'Vous devez désactiver le module avant de le désactiver!', :confirm => 'Vous devez désactiver le module'+feature.name, :method => :get)
       button = "<a class=\"admin_features_activated-installed\" href=\" \" title='Vous devez d&#146abord désactiver le module "+feature.name+"!' OnClick=\"alert ('Vous devez d&#146abord désactiver le module "+feature.name+"'); return false\">Oui</a>"
    else
      if feature.installed?
        button = link_to("Oui", {:action => "show", :id => feature.id}, :title=>'Cliquez ici pour désinstaller ['+feature.name+']',:class => 'admin_features_activated-installed', :method => :get)
      else 
        button = link_to("<div class=\"admin_features_non_activated-installed\"  >Non</div>", {:action => "install", :id => feature.id},:class => 'admin_features_non_activated-installed', :title=>'Cliquez ici pour installer ['+feature.name+']', :confirm => 'Voulez-vous installer le module ['+feature.name+'] ?', :method => :put) 
      end 
      button
    end 
  end    
 
  
  # Helper method to display the good link for the gestion of activation/deactivation of a feature
  def display_activate_link(feature)
    if feature.base_feature? and feature.is_kernel_feature? 
      if feature.activated?
        button= "<a class=\"admin_features_activated-installed\" href=\" \" title=\"Vous ne pouvez pas désactiver le module "+feature.name+" car c&#146est un module critique du noyau!\" Onclick=\"alert ('Vous ne devez pas désactiver le module "+feature.name+" car il appartient au noyau!');return false\" >Oui</a>"
      end
    elsif !feature.installed?
      # button = link_to("<div class=\"admin_features_non_activated-installed\" >Non</div>", {:action => "index", :id => feature.id}, :title=>'Vous devez installer le module avant de l\'activer!' , :onclick => 'alert( "Vous devez installer le module") '+feature.name , :method => :get)
      button = "<a class=\"admin_features_non_activated-installed\" href=\" \" title='Vous devez d&#146abord installer le module "+feature.name+"!' OnClick=\"alert ('Vous devez d&#146abord installer le module "+feature.name+"'); return false\">Non</a>"
    else
     if feature.activated? 
        button = link_to("Oui", {:action => "disable", :id => feature.id},  :title=>'Cliquez ici pour désactiverle module ['+feature.name+']',:class=>'admin_features_activated-installed', :confirm => 'Voulez-vous desactiver le module ['+feature.name+'] ?', :method => :put) 
      else
        button = link_to("Non", {:action => "enable", :id => feature.id},  :title=>'Cliquez ici pour activer le module ['+feature.name+']',:class=> 'admin_features_non_activated-installed', :confirm => 'Voulez-vous activer le module ['+feature.name+'] ?', :method => :put)
      end
    end
     button 
  end
  
  # Helper method to display the remove button
  def display_remove_link(feature)
    if feature.able_to_remove? and !feature.base_feature?
      unless feature.installed?
        return  link_to("<div class=\"admin_features_remove\">Supprimer</div>", {:action => "remove_feature", :id => feature.id}, :confirm => 'Voulez-vous vraiment Supprimer ?', :method => :put)
      end
    end
  end
  
end
