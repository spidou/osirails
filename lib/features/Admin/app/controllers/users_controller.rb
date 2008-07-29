class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    # TODO In the view index, add the sessions management
    @users = User.find(:all, :include =>[:employee])
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Le compte utilisateur a été ajouté avec succés.'
      redirect_to(@user) 
    else
      render :action => "new"
    end
  end

  #PUT /users/1
  #PUT /users/1.xml
  def update
    params[:user][:role_ids] ||= []
    @user = User.find(params[:id])
    unless params[:user][:password].empty?
      @user.updating_password = true
      @user.save
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Le compte utilisateur a été mis-à-jour avec succés.'
      redirect_to(@user) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
end