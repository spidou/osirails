class UsersController < ApplicationController
  # GET /users
  def index
    # TODO In the view index, add the sessions management
    @users = User.find(:all, :include =>[:employee])
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @roles = Role.find(:all, :order => :name)
  end

  # POST /users
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Le compte utilisateur a &eacute;t&eacute; ajout&eacute; avec succ&egrave;s.'
      redirect_to(@user) 
    else
      render :action => "new"
    end
  end

  #PUT /users/1
  def update
    params[:user] ||= []
    @user = User.find(params[:id])
    unless params[:user][:password].empty?
      @user.updating_password = true
      @user.save
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Le compte utilisateur a &eacute;t&eacute; mis-&agrave;-jour avec succ&egrave;s.'
      redirect_to(@user) 
    else
      @roles = Role.find(:all, :order => :name)
      render :action => "edit"
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
end