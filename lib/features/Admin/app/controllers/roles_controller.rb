class RolesController < ApplicationController
  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.find(:all)
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = 'Le Rôle a été ajouté avec succés.'
      redirect_to(@role) 
    else
      render :action => "new" 
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = 'Le Rôle a été mis-à-jour avec succés.'
      redirect_to(@role)
    else
      render :action => "edit" 
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to(roles_url) 
  end
  

end

