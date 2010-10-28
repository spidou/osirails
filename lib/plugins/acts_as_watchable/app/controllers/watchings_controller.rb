class WatchingsController < ApplicationController
  before_filter :define_watcher
  before_filter :define_watching,       :except => :new
  before_filter :define_watchable_type
  before_filter :define_watchable
  
  def new
    @return_uri = params[:return_uri]
    
    if @watchable.find_watching_with(@watcher.id)
      error_access_page(412)
    else
      @watching = Watching.new(:watchable_id => @watchable.id, :watchable_type => @watchable.class.name, :watcher => @watcher)
      @watching.build_missing_watchings_watchable_functions
      render :layout => false
    end
  end
  
  def create
    if @watching.save
      flash[:notice] = "Les modifications ont été sauvegardées"
      render :partial => 'update_watching_button_state', :locals => { :watchable => @watchable }
      #redirect_to params[:return_uri] # without AJAX
    else
      @watching.build_missing_watchings_watchable_functions
      render :action => "new", :layout => false
    end
  end
  
  def edit
    @return_uri = params[:return_uri]
    @watching.build_missing_watchings_watchable_functions
    render :layout => false
  end
  
  def update
    if @watching
      if @watching.update_attributes(params[:watching])
        flash[:notice] = "Les observations ont été modifié avec succès"
        render :partial => 'update_watching_button_state', :locals => { :watchable => @watchable }
        #redirect_to params[:return_uri] # without AJAX
      else
        render :action => "edit", :layout => false
      end
    else
      error_access_page(412)
    end
  end
  
  private
    def define_watcher
      @watcher = current_user
    end
    
    def define_watching
      if params[:id]
        @watching = Watching.find(params[:id])
      else
        @watching = Watching.new(params[:watching])
      end
    end
    
    def define_watchable_type
      if params[:action] == 'new' and params[:watchable_type]
        @watchable_type = params[:watchable_type].constantize
      else
        @watchable_type = @watching.watchable_type.constantize
      end
    end
    
    def define_watchable
      if params[:watchable_id]
        @watchable = @watchable_type.find(params[:watchable_id])
      else
        @watchable = @watchable_type.find(@watching.watchable_id)
      end
      
      error_access_page(412) unless @watchable
    end
end
