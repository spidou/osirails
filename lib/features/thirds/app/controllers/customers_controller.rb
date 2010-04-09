class CustomersController < ApplicationController
  helper :thirds, :establishments, :contacts, :documents, :numbers
  
  before_filter :hack_params_for_establishments_addresses, :only => [ :create, :update ]
  
  # GET /customers
  def index
    @customers = Customer.activates.paginate(:page => params[:page], :per_page => Customer::CUSTOMERS_PER_PAGE)
  end
  
  # GET /customers/:id
  def show
    @customer = Customer.find(params[:id])
    
    url     = @customer.logo.path(:thumb)
    options = {:filename => @customer.logo_file_name, :type => @customer.logo_content_type, :disposition => 'inline'}
    
    respond_to do |format|
      format.html
      format.jpg { send_data(File.read(url), options) }
      format.png { send_data(File.read(url), options) }
    end
  end
  
  # GET /customers/new
  def new
    @customer = Customer.new
    @customer.build_head_office
  end

  # POST /customers
  def create
    @return_uri = params[:return_uri] # permit to be redirected to order creation (or other uri) when necessary
    
    
    @customer = Customer.new(params[:customer])
    @customer.creator = current_user
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
      flash[:error] = "Une erreur est survenu lors de la suppression du client"
      redirect_to :back
    end
  end
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_establishments_addresses
      if params[:customer][:establishment_attributes]
        params[:customer][:establishment_attributes].each_with_index do |establishment_attributes, index|
          establishment_attributes[:address_attributes] = params[:establishment][:address_attributes][index] if params[:establishment][:address_attributes]
          establishment_attributes[:fax_attributes] = params[:establishment][:fax_attributes][index] if params[:establishment][:fax_attributes]
          establishment_attributes[:phone_attributes] = params[:establishment][:phone_attributes][index] if params[:establishment][:phone_attributes]
        end
        params.delete(:establishment)
      end
      if params[:customer][:head_office_attributes]
        params[:customer][:head_office_attributes].each_with_index do |head_office_attributes, index|
          head_office_attributes[:address_attributes] = params[:head_office][:address_attributes][index] if params[:head_office][:address_attributes]
          head_office_attributes[:fax_attributes] = params[:head_office][:fax_attributes][index] if params[:head_office][:fax_attributes]
          head_office_attributes[:phone_attributes] = params[:head_office][:phone_attributes][index] if params[:head_office][:phone_attributes]
        end
        params.delete(:head_office)
      end
    end

end
