class FeaturesController < ApplicationController
  # GET /features
  def index
    @features = Feature.find(:all, :order => "installed, activated DESC, name")
  end

  # GET /features/1
  def show
    @feature = Feature.find(params[:id])
  end

  # POST /features
  def create
    file_to_upload = {:file => params[:upload]}

    if Feature.add(file_to_upload)
      flash[:notice] = "Fichier envoy&eacute; et ajout&eacute; avec succ&egrave;s."
    else
      flash[:error] = "Erreur lors de l'envoi du fichier"
    end

    redirect_to features_path
  end

  # PUT /features/1
  def update
    @feature = Feature.find(params[:id])

    flash[:notice] = "Le module '#{@feature.title}' a &eacute;t&eacute; "
    case params[:state]
    when 'enable'
      if @feature.enable
        flash[:notice] << "activ&eacute;"
      else
        flash[:error] = "Une erreur est survenue lors de l'activation du module '#{@feature.title}'. "
        unless @feature.activate_dependencies.empty?
          @feature.activate_dependencies.size > 1 ? flash[:error] << "Les modules suivants sont requis : " : flash[:error] << "Le module suivant est requis : "
          deps = []
          @feature.activate_dependencies.each do |error|
            deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
          end
          flash[:error] << deps.join(", ")
        end
      end
    when 'disable'
      if @feature.disable
        flash[:notice] << "d&eacute;sactiv&eacute;"
      else
        flash[:error] = "Une erreur est survenue lors de la désactivation du module '#{@feature.title}'. "
        unless @feature.deactivate_children.empty?
          @feature.deactivate_children.size > 1 ? flash[:error] << "D'autres modules dépendent de ce module : " : flash[:error]  << "Un autre module dépend de ce module : "
          deps = []
          @feature.deactivate_children.each do |error|
            deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
          end
          flash[:error] << deps.join(", ")
        end
      end
    when 'install'
      if @feature.install
        flash[:notice] << "install&eacute;"
      else
        flash[:error] = "Une erreur est survenue lors de l'installaton du module '#{@feature.title}'. "
        unless @feature.able_to_install_dependencies.empty?
          @feature.able_to_install_dependencies.size > 1 ? flash[:error] << "Les modules suivants sont requis : " : flash[:error] <<  "Le module suivants est requis : "
          deps = []
          @feature.able_to_install_dependencies.each do |error|
            deps << "#{error[:name]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
          end
          flash[:error] << deps.join(", ")
        end
        unless @feature.able_to_install_conflicts.empty?
          @feature.able_to_install_conflicts.size > 1 ? flash[:error] << "<br/>Les conflits suivants ont été détectés : " : flash[:error] << "<br />Le conflit suivant a été détecté : "
          deps = []
          @feature.able_to_install_conflicts.each do |error|
            deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
          end
          flash[:error] << deps.join(", ")
        end
        unless @feature.install_log.empty?
          @feature.install_log.each do |error|
            flash[:error] << "<br />" + error
          end
        end
      end
    when 'uninstall'
      if @feature.uninstall
        flash[:notice] << "d&eacute;sinstall&eacute;"
      else
        flash[:error] = "Une erreur est survenue lors de la désinstallation du module '#{@feature.title}'. "
        unless @feature.able_to_uninstall_children.empty?
          flash[:error] << "D'autres modules dépendent de ce module : "
          deps = []
          @feature.able_to_uninstall_children.each do |error|
            deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
          end
          flash[:error] << deps.join(", ")
        end
        unless @feature.uninstall_log.empty?
          @feature.uninstall_log.each do |error|
            flash[:error] << "<br />" + error
          end
        end
      end
    end

    flash.delete(:notice) if flash[:error]

    redirect_to features_path
  end

  # DELETE /features/1
  def delete
    @feature = Feature.find(params[:id])

    if @feature.remove
      flash[:notice] = "Le module '#{@feature.title}' a &eacute;t&eacute; supprim&eacute;"
    else
      flash[:error] = "Une erreur est survenue lors de la suppression du module '#{@feature.title}'."
    end

    redirect_to feature_path
  end
end
