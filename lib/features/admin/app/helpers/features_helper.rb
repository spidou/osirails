module FeaturesHelper
  # Helper method to display the good link for the gestion of installation/uninstallation of a feature
  def display_install_link(feature)
    if Feature.can_edit?(current_user)
      if feature.base_feature? 
        button = "<a class=\"admin_features_activated-installed\" href=\" \" title='Vous ne pouvez pas désinstaller le module "+feature.title+" car il appartient au noyau  !' Onclick=\"alert ('Vous ne devez pas désinstaller le module "+feature.title+" car il appartient au noyau  ! ');return false\" ><img src='/images/tick_16x16.png' atl='Activer' title='Cliquer pour d&eacute;activer' /></a>" if feature.installed?
      elsif feature.activated?
        button = "<a class=\"admin_features_activated-installed\" href=\" \" title='Vous devez d&#146abord désactiver le module "+feature.title+"!' OnClick=\"alert ('Vous devez d&#146abord désactiver le module "+feature.title+"'); return false\"><img src='/images/tick_16x16.png' atl='Activer' title='Activer' /></a>"
      else
        if feature.installed?
          button = link_to("<img src='/images/tick_16x16.png' atl='Activer' title='Cliquer pour d&eacute;activer' />", feature_path(feature), :title=>'Cliquez ici pour désinstaller ['+feature.title+']',:class => 'admin_features_activated-installed', :method => :get)
        else 
          button = link_to("<img src='/images/cross_16x16.png' atl='D&eacute;activer' title='Cliquer pour activer' />", feature_path(feature, :state => 'install'),:class => 'admin_features_non_activated-installed', :title=>'Cliquez ici pour installer ['+feature.title+']', :confirm => 'Voulez-vous installer le module ['+feature.title+'] ?', :method => :put) 
        end 
        button
      end
    end
  end

  # Helper method to display the good link for the gestion of activation/deactivation of a feature
  def display_activate_link(feature)
    if Feature.can_edit?(current_user)
      if feature.base_feature? and feature.kernel_feature? 
        if feature.activated?
          button = "<a class=\"admin_features_activated-installed\" href=\" \" title=\"Vous ne pouvez pas désactiver le module "+feature.name+" car c&#146est un module critique du noyau!\" Onclick=\"alert ('Vous ne devez pas désactiver le module "+feature.title+" car il appartient au noyau!');return false\" ><img src='/images/tick_16x16.png' atl='Activer' title='Cliquer pour d&eacute;sactiver' /></a>"
        end
      elsif !feature.installed?
        button = "<a class=\"admin_features_non_activated-installed\" href=\" \" title='Vous devez d&#146abord installer le module "+feature.title+"!' OnClick=\"alert ('Vous devez d&#146abord installer le module "+feature.title+"'); return false\"><img src='/images/cross_16x16.png' atl='D&eacute;sactiver' title='Cliquer pour activer' /></a>"
      else
       if feature.activated? 
         button = link_to("<img src='/images/tick_16x16.png' atl='Activer' title='Cliquer pour d&eacute;activer' />", feature_path(feature, :state => 'disable'), :title => 'Cliquez ici pour désactiverle module ['+feature.title+']',:class => 'admin_features_activated-installed', :confirm => 'Voulez-vous desactiver le module ['+feature.title+'] ?', :method => :put) 
        else
          button = link_to("<img src='/images/cross_16x16.png' atl='D&eacute;activer' title='Cliquer pour activer' />", feature_path(feature, :state => 'enable'), :title => 'Cliquez ici pour activer le module ['+feature.title+']',:class => 'admin_features_non_activated-installed', :confirm => 'Voulez-vous activer le module ['+feature.title+'] ?', :method => :put)
        end
      end
      button
    end
  end

  # Helper method to display the remove button
  def display_remove_link(feature)
    if Feature.can_delete?(current_user)
      if feature.able_to_remove? and !feature.base_feature?
        unless feature.installed?
          return  link_to("<img src='/images/delete_16x16.png' atl='Supprimer' title='Supprimer' />", feature_path(feature), :confirm => 'Voulez-vous vraiment Supprimer ?', :method => :delete)
        end
      end
    end
  end
end
