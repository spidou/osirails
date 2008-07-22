class FeaturesController < ApplicationController

  def index
    @features = Osirails::Feature.find(:all)

    respond_to do |format|
      format.html
      format.xml {render :xml => @features}
    end
  end

  def enable
    @feature = Osirails::Feature.find(params[:id])
    @feature.enable
    # TODO Faire le même affichage des flashs que ceux en bas. Manque: features_not_activated
    flash[:notice] = @feature.name + " est activé."
    redirect_to features_path
  end

  def disable
    @feature = Osirails::Feature.find(params[:id])
    @feature.disable
    # TODO Pareil pour: children_activated
    flash[:notice] = @feature.name + " est désactivé."
    redirect_to features_path
  end
  
  def install
    @feature = Osirails::Feature.find(params[:id])
    if @feature.install
      flash[:notice] = @feature.name + " est installé."
    else
      flash[:error] = "Erreur(s) lors de l'installation de " + @feature.name
      unless @feature.missing_dependencies.empty?
        flash[:error] << "<br />Dépendance(s) requise(s): "
        @feature.missing_dependencies.each do |error|
          flash[:error] << "<br />" + error[:name] + " [" + error[:version].join(" | ") + "]"
        end
      end
      unless @feature.feature_conflicts.empty?
        flash[:error] << "<br />Conflit(s) détecté(s): "
        @feature.feature_conflicts.each do |error|
          flash[:error] << "<br />" + error[:name] + " [" + error[:version].join(" | ") + "]"
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

  def uninstall
    @feature = Osirails::Feature.find(params[:id])
    if @feature.uninstall
      flash[:notice] = @feature.name + " est désinstallé"
    else
      flash[:error] = "Erreur(s) lors de la désinstallation de " + @feature.name
      unless @feature.features_uninstallable.empty?
        flash[:error] << "<br />D'autres modules dépendent de ce module: "
        @feature.features_uninstallable.each do |error|
          flash[:error] << "<br />" + error[:name] + " Versions: " + error[:version]
        end
      end
      unless @feature.uninstallation_messages.empty?
        @feature.uninstallation_messages.each do |error|
          flash[:error] << "<br />" + error
        end
      end      

    end
    redirect_to features_path
  end
end