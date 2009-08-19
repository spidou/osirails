class UsersController < ApplicationController

  #Callbacks
  before_filter :load_collections, :only => [:new, :create, :edit, :update]

  # GET /users
  def index
    # TODO In the view index, add the sessions management
    @users = User.find(:all).paginate(:page => params[:page], :per_page => User::USERS_PER_PAGE)
  end

  # GET /users/1
  def show
    @user = User.find(params[:id]) 
    @roles = @user.roles
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
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
    return if params[:user].empty?

    @user = User.find(params[:id])
    
    if params[:user][:password].empty?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    else
      @user.updating_password = true
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = 'Le compte utilisateur a &eacute;t&eacute; mis-&agrave;-jour avec succ&egrave;s.'
      redirect_to(@user) 
    else
      render :action => "edit"
    end
    @user.updating_password = false
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    unless @user.destroy
      flash[:notice] = 'Impossible de supprimer l&apos;utilisateur'    
    end
    redirect_to(users_url) 
  end

  private

  def load_collections
     @roles = Role.find(:all, :order => "name")
  end  
end
