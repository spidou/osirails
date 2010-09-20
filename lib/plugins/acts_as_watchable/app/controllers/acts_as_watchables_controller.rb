class ActsAsWatchablesController < ApplicationController
  
  before_filter :define_watcher_user

  def define_watcher_user
    @watcher_user = watcher_user
  end
  
  def watcher_user
    current_user
  end
  
  def edit
    @watchable = Watchable.find(params[:id])
    @object = @watchable.has_watchable_type.constantize.find(@watchable.has_watchable_id)
    @watchable.watchables_watchable_functions = @watchable.build_watchables_watchable_function_with(@object.watchable_functions)
    @return_uri = params[:return_uri]
    render :layout => false
  end
  
  def new
    if (params['object_id'] != "" && params['object_type'] != "" && (@object = params['object_type'].constantize.find(params['object_id'].to_i)) != nil)
      @return_uri = params[:return_uri]
      if @watchable = @object.find_watchable_with(@watcher_user.id)
        error_access_page(412)
      else
        @watchable = Watchable.new
        @watchable.watchables_watchable_functions = @watchable.build_watchables_watchable_function_with(@object.watchable_functions)
        render :layout => false
      end
    else
      error_access_page(412)
    end
  end
  
  def create
    @watchable = Watchable.new(params[:watchable])
    @object = @watchable.has_watchable_type.constantize.find(@watchable.has_watchable_id)
    if @watchable.save
      flash[:notice] = "#{@object.class.name} est actuellement observ&eacute;"
      render :partial => 'ajax_form_tools', :locals => {:object => @object, :watchable => @watchable} 
      #Redirect for use without AJAX
      #redirect_to params[:return_uri]
    else
      @watchable.watchables_watchable_functions = @watchable.build_watchables_watchable_function_with(@object.watchable_functions)
      render :action => "new", :layout => false
    end
  end
  
  def update
    if @watchable = Watchable.find(params[:id])
      @object = @watchable.has_watchable_type.constantize.find(@watchable.has_watchable_id)
      if @watchable.update_attributes(params[:watchable])
        flash[:notice] = "vos observations ont ete modifie avec succes"
        render :partial => 'ajax_form_tools', :locals => {:object => @object, :watchable => @watchable} 
        #Redirect for use without AJAX
        #redirect_to params[:return_uri]
      else
        render :action => "edit", :layout => false
      end
    else
      error_access_page(412)
    end
  end
   
end
