class FeaturesController < ApplicationController

  #Method to collect features and to show them into the index view
  def index
    @features = Osirails::Feature.find(:all)

    respond_to do |format|
      format.html
      format.xml {render :xml => @features}
    end
  end

  # Method to show up messages concerning features enabling
  #flash[:notice] shows method's succes message
  #flash[:error] shows method's failure message with some details concerning dependances  
  def enable
    @feature = Osirails::Feature.find(params[:id])
   if  @feature.enable
     flash[:notice] = @feature.name + " est activé."
   else  
     flash[:error] = "Erreur(s) lors de l'activation de " + @feature.name
     unless @feature.features_not_activated.empty?
       flash[:error] << "<br /><br />Dépendance(s) non activés requise(s): "
       @feature.features_not_activated.each do |error|
          flash[:error] << "<br />" + error[:name] + " [ v:" + error[:version] +  "]"
       end
     end
   end
    redirect_to features_path
  end

 # Method to show up messages concerning features disabling
 #flash[:notice] shows method's succes message
 #flash[:error] shows method's failure message with some details concerning modules depending current module
  def disable
    @feature = Osirails::Feature.find(params[:id])
     if @feature.disable
      flash[:notice] = @feature.name + " est désactivé."
     else
      flash[:error] = "Erreur(s) lors de la désactivation de " + @feature.name
        unless @feature.children_activated.empty?
          flash[:error] << "<br /><br />D'autres modules dépendent de ce module: "
           @feature.children_activated.each do |error|
              flash[:error] << "<br />" + error[:name] + " [ v:" + error[:version] + "]"
           end
        end
     end
    redirect_to features_path
  end
  
  # Method to show up messages concerning features installing
  #flash[:notice] shows method's succes message
  #flash[:error] shows method's failure message with some details concerning dependance and conflicting modules
  def install
    @feature = Osirails::Feature.find(params[:id])
    if @feature.install
      flash[:notice] = @feature.name + " est installé."
    else
      flash[:error] = "Erreur(s) lors de l'installation de " + @feature.name
      unless @feature.missing_dependencies.empty?
        flash[:error] << "<br /><br />Dépendance(s) non installés requise(s): "
        @feature.missing_dependencies.each do |error|
          flash[:error] << "<br />" + error[:name] + " [ v:" + error[:version].join(" | v: ") + "]"
        end
      end
      unless @feature.feature_conflicts.empty?
        flash[:error] << "<br />Conflit(s) détecté(s): "
        @feature.feature_conflicts.each do |error|
          flash[:error] << "<br />" + error[:name] + " [ v:" + error[:version].join(" | v: ") + "]"
        end
      end
      unless @feature.installation_messages.empty?
        @feature.installation_messages.each do |error|
          flash[:error] << "<br />" + error
        end
      end
    end
    redirect_to features_path
  end
  
  # Method to show up messages concerning features uninstalling
  #flash[:notice] shows method's succes message
  #flash[:error] shows method's failure message with some details concerning modules depending current module
  def uninstall
    @feature = Osirails::Feature.find(params[:id])
    if @feature.uninstall
      flash[:notice] = @feature.name + " est désinstallé"
    else
      flash[:error] = "Erreur(s) lors de la désinstallation de " + @feature.name
      unless @feature.features_uninstallable.empty?
        flash[:error] << "<br /><br />D'autres modules dépendent de ce module: "
        @feature.features_uninstallable.each do |error|
          flash[:error] << "<br />" + error[:name] + " [v: " + error[:version]+"]"
        end
      end
      unless @feature.uninstallation_messages.empty?
        @feature.uninstallation_messages.each do |error|
          flash[:error] << "<br />" + error
        end
      end      
    end
      redirect_to  :action => "show"
  end
  
    def show
    @feature = Osirails::Feature.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feature }
    end
  end
end
