module FeaturesHelper
  
  #helper method to display the good control button for the gestion of installation/uninstallation of a feature
  def display_install_button(feature)
    if feature.installed? and !feature.activated?
      button = button_to("Désinstaller", {:action => "uninstall", :id => feature.id}, :method => :put)
    elsif !feature.installed? 
      button = button_to("Installer", {:action => "install", :id => feature.id}, :confirm => 'Voulez-vous installer ?', :method => :put) 
    end 
    button
  end    
 
  
  #helper method to display the good control button for the gestion of activation/deactivation of a feature
  def display_activate_button(feature)
    if feature.activated?
      button = button_to("Desactiver", {:action => "disable", :id => feature.id}, :confirm => 'Voulez-vous desactiver ?', :method => :put) 
    elsif feature.installed? 
      button = button_to("Activer", {:action => "enable", :id => feature.id}, :confirm => 'Voulez-vous activer ?', :method => :put)
    end
    button    
  end
  
  #helper method to display the good control button for the gestion of installation/uninstallation of a feature
  def display_install_link(feature)
    if feature.installed?
      button = link_to("<div class=\"admin_features_activated-installed\">Oui</div>", {:action => "uninstall", :id => feature.id}, :method => :put)
    else 
      button = link_to("<div class=\"admin_features_non_activated-installed\">Non</div>", {:action => "install", :id => feature.id}, :confirm => 'Voulez-vous installer ?', :method => :put) 
    end 
    button
  end    
 
  
  #helper method to display the good control button for the gestion of activation/deactivation of a feature
  def display_activate_link(feature)
    if feature.activated?
      button = link_to("<div class=\"admin_features_activated-installed\">Oui</div>", {:action => "disable", :id => feature.id}, :confirm => 'Voulez-vous desactiver ?', :method => :put) 
    else
      button = link_to("<div class=\"admin_features_non_activated-installed\">Non</div>", {:action => "enable", :id => feature.id}, :confirm => 'Voulez-vous activer ?', :method => :put)
    end
    button    
  end
  
  #helper method to display the remove button
  def display_remove_button(feature)
    unless feature.installed
    return  button_to("Supprimer", {:action => "remove_feature", :id => feature.id}, :confirm => 'Voulez-vous vraiment Supprimer ?', :method => :put)
    end
  end
  
  # helper method to display the good Flash message
  def display_success_flash
     if flash[:notice]
      "<p class=\"admin_features_activated-installed\">"+flash[:notice]+"</p>"
     end
  end
  
  # helper method to display the good Flash message
  def display_failure_flash
     if flash[:error] 
     "<p class=\"admin_features_non_activated-installed\">" +flash[:error]+"</p>"
     end
  end
  
end
