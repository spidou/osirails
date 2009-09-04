class SuppliersController < ApplicationController

  helper :thirds, :contacts, :documents

  # GET /suppliers
  def index
    @suppliers = Supplier.activates
  end

  # GET /suppliers/:id
  def show
    @supplier = Supplier.find(params[:id])
    @contacts = @supplier.contacts
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
  end

  # POST /suppliers
  def create
    @supplier = Supplier.new(params[:supplier])
    if @supplier.save
      flash[:notice] = "Fournisseur ajout&eacute; avec succ&egrave;s"
      redirect_to supplier_path(@supplier)
    else
      render :action => 'new'
    end
  end

  # GET /suppliers/:id/edit
  def edit
    @supplier = Supplier.find(params[:id])
    @contacts = @supplier.contacts
  end

  # PUT /suppliers/:id
  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update_attributes(params[:supplier])
      flash[:notice] = "Le fournisseur a été modifié avec succès"
      redirect_to supplier_path(@supplier)
    else
      render :action => 'edit'
    end
  end

  # DELETE /supplier/:id
  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.activated = false
    if @supplier.save
      redirect_to(suppliers_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression du fournisseur"
      redirect_to :back
    end
  end
end
