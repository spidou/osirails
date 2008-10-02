class FeaturesController < ApplicationController

  # Add permissions for methods
  method_permission(:edit => ['disable', 'enable', 'install', 'uninstall', 'change_state'], :delete => ['remove_feature'], :new => ['add_feature'])

  # Method to collect features and to show them into the index view
  def index
    @features = Feature.find(:all, :order => "installed, activated DESC, name")
  end
  
  # method to show warning message about uninstallation and to confirm the uninstallation
  def show
    @feature = Feature.find(params[:id])
  end
  
  
  # flash[:notice] shows method's succes message
  # flash[:error] shows method's failure message with some details concerning dependances  
  def change_state(method) 
    @feature = Feature.find(params[:id])   
    
    if @feature.send(method)
      flash[:notice] = @feature.display_flash_notice(method) 
    else 
      flash[:error] = @feature.display_flash_error(method)  
    end
    redirect_to features_path
  end
  
  # Method for untar an uploaded feature to the default feature path
  def add_feature
    file_to_upload = {:file => params[:upload]}
    state = Feature.add(file_to_upload)
    
    if state == true
      flash[:notice] = "Fichier envoy&eacute; et ajout&eacute; avec succ&egrave;s."
    elsif state == false
      flash[:error] = "Erreur lors de l'envoi du fichier"
    else
      flash[:error] = "#{state}"
    end
    redirect_to features_path
  end
  
  # Method to show up messages concerning features removing
  # it call the generic method change state below and pass into arguments his name
  def remove_feature
   self.change_state("remove")
  end

  # Method to show up messages concerning features enabling
  # it call the generic method change state below and pass into arguments his name
  def enable
    self.change_state("enable")
  end

 # Method to show up messages concerning features disabling
# it call the generic method change state below and pass into arguments his name
  def disable
    self.change_state("disable")
  end

  # Method to show up messages concerning features installing
# it call the generic method change state below and pass into arguments his name
  def install
   self.change_state("install")
  end
  
  # Method to show up messages concerning features uninstalling
# it call the generic method change state below and pass into arguments his name 
  def uninstall
   self.change_state("uninstall")
  end
  
end
