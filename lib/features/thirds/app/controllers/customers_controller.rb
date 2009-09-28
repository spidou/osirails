class CustomersController < ApplicationController
  helper :thirds, :establishments, :contacts, :documents
  
  before_filter :hack_params_for_establishments_addresses, :only => [ :create, :update ]
  
  # GET /customers
  def index
    @customers = Customer.activates.paginate(:page => params[:page], :per_page => Customer::CUSTOMERS_PER_PAGE)
  end
  
  # GET /customers/:id
  def show
    @customer = Customer.find(params[:id])
  end
  
  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # POST /customers
  def create
    @return_uri = params[:return_uri] # permit to be redirected to order creation (or other uri) when necessary
    
    @customer = Customer.new(params[:customer])
    if @customer.save
      flash[:notice] = "Client ajouté avec succès"
      @return_uri ? redirect_to( url_for(:controller => @return_uri, :new_customer_id => @customer.id) ) : redirect_to(customer_path(@customer))
    else
      render :action => 'new'
    end
  end

  # GET /customers/:id/edit
  def edit
    @customer = Customer.find(params[:id])
    #@establishments = @customer.activated_establishments
    @contacts = @customer.contacts
    @documents = @customer.documents
    @activity_sector = @customer.activity_sector.name unless @customer.activity_sector.nil?
    
    respond_to do |format|
      #params[:page] ||= 1
      params[:type] == "popup" ? format.html {render :layout => 'popup'} : format.html
      @javascript = "<script langage='javascript'> parent.document.getElementById('testpage').innerHTML = document.getElementById('testpage').innerHTML</script>"
      format.js { render( :layout => false, :partial => 'documents/edit_partial', :locals => {:document => (Document.find(params[:document_id]) unless params[:document_id].nil?), :javascript => @javascript})}
    end
  end

  # PUT /customers/:id
  def update
    @customer = Customer.find(params[:id])
    if @customer.update_attributes(params[:customer])
      flash[:notice] = "Le client a été modifié avec succès"
      redirect_to customer_path(@customer)
    else
      render :action => 'edit'
    end
  end

  # DELETE /customers/:id
  def destroy
    @customer = Customer.find(params[:id])
    @customer.activated = false
    if @customer.save
      redirect_to(customers_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression du contact"
      redirect_to :back 
    end
  end
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_establishments_addresses
      # raise params.inspect
      if params[:customer][:establishment_attributes] and params[:establishment][:address_attributes]
        params[:customer][:establishment_attributes].each_with_index do |establishment_attributes, index|
          establishment_attributes[:address_attributes] = params[:establishment][:address_attributes][index]
        end
        params.delete(:establishment)
      end
    end

end
