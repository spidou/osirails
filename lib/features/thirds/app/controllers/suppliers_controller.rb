class SuppliersController < ApplicationController
  helper :thirds, :contacts, :documents, :numbers, :address
  
  before_filter :hack_params_for_contacts_nested_resources, :only => [ :create, :update ]
  
  # GET /suppliers
  def index
    @suppliers = Supplier.activates.paginate(:page => params[:page], :per_page => Supplier::SUPPLIERS_PER_PAGE)
  end

  # GET /suppliers/:id
  def show
    @supplier = Supplier.find(params[:id])
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
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_contacts_nested_resources
      if params[:contact] and params[:contact][:number_attributes]
        params[:supplier][:contact_attributes].each do |contact_attributes|
          number_attributes = params[:contact][:number_attributes].select {|n| contact_attributes[:id] == n[:has_number_id]}
          contact_attributes[:number_attributes] = clean_params(number_attributes, :has_number_id)
        end
      end
      remove_fake_ids(params[:supplier][:contact_attributes])
      params.delete(:contact)
    end
end
