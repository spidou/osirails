class SuppliersController < ApplicationController

  helper :thirds, :contacts, :documents

  # GET /suppliers
  # GET /suppliers.xml
  def index
    if Supplier.can_list?(current_user)
      @suppliers = Supplier.activates
    else
      error_access_page(403)
    end
  end

  # GET /suppliers/1
  # GET /suppliers/1.xml
  def show
    ## Objects use to test permission
    @contact_controller = Menu.find_by_name('contacts')

    if Supplier.can_view?(current_user)
      @supplier = Supplier.find(params[:id])
      @contacts = @supplier.contacts
    else
      error_access_page(403)
    end
  end

  # GET /suppliers/new
  def new
    if Supplier.can_add?(current_user)
      @supplier = Supplier.new
    else
      error_access_page(403)
    end
  end

  # POST /suppliers
  def create
    if Supplier.can_add?(current_user)
      @supplier = Supplier.new(params[:supplier])
      if @supplier.save
        flash[:notice] = "Fournisseur ajout&eacute; avec succ&egrave;s"
        redirect_to supplier_path(@supplier)
      else
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end

  # GET /suppliers/1/edit
  def edit
    ## Objects use to test permission
    @contact_controller = Menu.find_by_name('contacts')
    @establishment_controller = Menu.find_by_name('establishments')

    if Supplier.can_edit?(current_user)
      @supplier = Supplier.find(params[:id])
      @contacts = @supplier.contacts
    else
      error_access_page(403)
    end
  end

  # PUT /suppliers/1
  def update
    if Supplier.can_edit?(current_user)
      @supplier = Supplier.find(params[:id])
      if @supplier.update_attributes(params[:supplier])
        flash[:notice] = "Le fournisseur a été modifié avec succès"
        redirect_to supplier_path(@supplier)
      else
        render :action => 'edit'
      end
    else
      error_access_page(403)
    end
  end

  # DELETE /supplier/1
  def destroy
    if Supplier.can_delete?(current_user)
      @supplier = Supplier.find(params[:id])
      @supplier.activated = false
      if @supplier.save
        redirect_to(suppliers_path)
      else
        flash[:error] = "Une erreur est survenu lors de la suppression du fournisseur"
        redirect_to :back
      end
    else
      error_access_page(403)
    end
  end
end
