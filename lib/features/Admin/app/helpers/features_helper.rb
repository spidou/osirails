module FeaturesHelper
  
  #helper method to display the good control button for the gestion of installation/uninstallation of a feature
  def dispay_install_button(feature)
    if feature.installed? and !feature.activated?
      button = button_to "Désinstaller", {:action => "uninstall", :id => feature.id}, :confirm => 'Voulez-vous désinstaller ?', :method => :put 
    elsif !feature.installed? 
      button = button_to "Installer", {:action => "install", :id => feature.id}, :confirm => 'Voulez-vous installer ?', :method => :put 
    end 
    button
  end    
 
  
  #helper method to display the good control button for the gestion of activation/deactivation of a feature
  def diplay_activate_button(feature)
    if feature.activated?
      button = button_to "Desactiver", {:action => "disable", :id => feature.id}, :confirm => 'Voulez-vous desactiver ?', :method => :put 
    elsif feature.installed? 
      button = button_to "Activer", {:action => "enable", :id => feature.id}, :confirm => 'Voulez-vous activer ?', :method => :put
    end
    button    
  end
  
end
