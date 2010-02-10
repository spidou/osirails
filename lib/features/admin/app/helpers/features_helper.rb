module FeaturesHelper
  # Helper method to display the good link for the gestion of installation/uninstallation of a feature
  def display_install_link(feature)
    if Feature.can_edit?(current_user)
      activated_image                   = image_tag("tick_16x16.png", :alt => "Activer", :title => "Cliquer pour désactiver")
      deactivated_image                 = image_tag("cross_16x16.png", :alt => "Désactiver", :title => "Cliquer pour activer")
      unable_to_uninstall_core_feature = "Vous ne pouvez pas désinstaller le module \"#{feature.title}\" car il appartient au noyau"
      unable_to_uninstall_feature      = "Vous devez d'abord désactiver le module \"#{feature.title}\""
      
      if feature.base_feature?
        button = link_to(activated_image, "#", :class => "admin_features_activated-installed", :onclick => "alert('#{unable_to_uninstall_core_feature}'); return false") if feature.installed?
      elsif feature.activated?
        button = link_to(activated_image, "#", :class => "admin_features_activated-installed", :onclick => "alert('#{unable_to_uninstall_feature}'); return false") if feature.installed?
      else
        if feature.installed?
          button = link_to(activated_image, feature_path(feature), :class => "admin_features_activated-installed", :method => :get)
        else 
          button = link_to(deactivated_image, feature_path(feature, :state => 'install'), :class => "admin_features_non_activated-installed", :method => :get, :confirm => "Voulez-vous installer le module \"#{feature.title}\" ?", :method => :put)
        end 
        button
      end
    end
  end

  # Helper method to display the good link for the gestion of activation/deactivation of a feature
  def display_activate_link(feature)
    if Feature.can_edit?(current_user)
      activated_image   = image_tag("tick_16x16.png", :alt => "Activer", :title => "Cliquer pour désactiver")
      deactivated_image = image_tag("cross_16x16.png", :alt => "Désactiver", :title => "Cliquer pour activer")
      unable_to_deactivate_core_feature = "Vous ne pouvez pas désactiver le module \"#{feature.title}\" car il appartient au noyau"
      unable_to_activate_feature = "Vous devez d'abord installer le module \"#{feature.title}\""
      
      if feature.base_feature? and feature.kernel_feature? 
        if feature.activated?
          button = link_to(activated_image, "#", :class => "admin_features_activated-installed", :onclick => "alert('#{unable_to_deactivate_core_feature}'); return false;")
        end
      elsif !feature.installed?
        button = link_to(activated_image, "#", :class => "admin_features_non_activated-installed", :onclick => "alert('#{unable_to_activate_feature}'); return false;")
      else
        if feature.activated? 
          button = link_to(activated_image, feature_path(feature, :state => 'disable'), :class => "admin_features_activated-installed", :confirm => "Voulez-vous desactiver le module \"#{feature.title}\" ?", :method => :put)
        else
          button = link_to(deactivated_image, feature_path(feature, :state => 'enable'), :class => "admin_features_non_activated-installed", :confirm => "Voulez-vous activer le module \"#{feature.title}\" ?", :method => :put)
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
          return link_to(image_tag("delete_16x16.png", :alt => delete_text = "Supprimer", :title => delete_text), feature_path(feature), :confirm => 'Voulez-vous vraiment supprimer ce module ?', :method => :delete)
        end
      end
    end
  end
end
