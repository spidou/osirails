class CheckingsController < ApplicationController
  before_filter :load_subordinates, :except => [ :destroy, :cancel ]
  
  # GET /checkings
  def index
    if !current_user.employee.nil?
      @view_cancelled = params[:cancelled] || false                                                    # if true permit to see cancelled checkings     
      @employee       = ( Employee.find(params[:employee_id].to_i) rescue nil ) || @subordinates.first
      @date           = (params[:date] || Date.today.monday).to_date
      @chekings       = []
      
      unless @employee.nil?
        options = {:conditions => ["date >= ? and date <= ?", @date, @date.next_week.yesterday], :order => :date}
        if @view_cancelled
          @checkings = @employee.checkings.all(options)
          flash.now[:warning] = "Les pointages annulés sont également visible sur cette page"
        else
          @checkings = @employee.checkings.actives.all(options)
        end
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /checkings/new
  def new
    if !current_user.employee.nil?
      @checking = Checking.new
      @checking.employee_id = params[:employee_id] || nil
    else
      error_access_page(403)
    end
  end
  
  # POST /checkings
  def create
    @checking = Checking.new(params[:checking])
    @checking.user = current_user
    
    #TODO test if transaction is effectively useful to avoid creating multiple checkings for same
    #     employee and date (if 2 users create simultaneously a checking for same employee and date)
    Checking.transaction do
      if @checking.save
        flash[:notice] = "Pointage ajouté avec succès"
        redirect_to checkings_path(:date => @checking.date, :employee_id => @checking.employee_id)
      else
        render :action => "new"
      end
    end
  end
  
  # GET /checkings/:id
  def edit
    if !current_user.employee.nil?
      @checking = Checking.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  # PUT /checkings/:id
  def update
    @checking = Checking.find(params[:id])
    if @checking.update_attributes(params[:checking])
      flash[:notice] = "Pointage modifié avec succès"
      redirect_to checkings_path(:date => @checking.date, :employee_id => @checking.employee_id)
    else
      render :action => "edit"
    end
  end
  
  # GET /checkings/:id/override_form
  def override_form
    if !current_user.employee.nil?
      @checking = Checking.find(params[:id])
    else
      error_access_page(403)
    end
  end
  
  # PUT /checkings/:id/override
  def override
    @checking = Checking.find(params[:id])
    @checking.attributes = params[:checking]
    if @checking.override
      flash[:notice] = "Pointage corrigé avec succès"
      redirect_to checkings_path(:date => @checking.date, :employee_id => @checking.employee_id)
    else
      render :action => "override_form"
    end
  end
  
  # DELETE /checkings/:id
  def destroy
    @checking = Checking.find(params[:id])
    unless @checking.destroy
      flash[:error] = "Impossible de supprimer le pointage"
    end
    redirect_to checkings_path
  end
  
  # GET /checkings/:id/cancel
  def cancel
    @checking = Checking.find(params[:id])
    unless @checking.cancel
      flash[:error] = "Impossible d'annuler le pointage"
    end
    redirect_to checkings_path
  end
  
  private
    def load_subordinates
      @subordinates = current_user.employee ? current_user.employee.subordinates : []
    end
  
end
