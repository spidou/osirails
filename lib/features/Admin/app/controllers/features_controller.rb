class FeaturesController < ApplicationController

  # Method to collect features and to show them into the index view
  def index
    @features = Feature.find(:all)
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
    Feature.add(file_to_upload) ? flash[:notice] = "Fichier envoy&eacute; et ajout&eacute; avec succ&egrave;s." : flash[:error] = "Erreur lors de l'envoi du fichier"
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
