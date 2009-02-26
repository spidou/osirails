class RolesController < ApplicationController

  # GET /roles
  def index
    @roles = Role.find(:all)
  end

  # GET /roles/1
  def show
    @role = Role.find(params[:id])
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = 'Le r&ocirc;le a &eacute;t&eacute; ajout&eacute; avec succ&egrave;s.'
      redirect_to(@role) 
    else
      render :action => "new"
    end
  end

  # PUT /roles/1
  def update
    params[:role][:user_ids] ||= []
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = 'Le r&ocirc;le a &eacute;t&eacute; mis-&agrave;-jour avec succ&egrave;s.'
      redirect_to(@role)
    else
      render :action => "edit" 
    end
  end

  # DELETE /roles/1
  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to(roles_url) 
  end
end
