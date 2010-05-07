class CustomersController < ApplicationController
  helper :thirds, :establishments, :contacts, :documents, :numbers
  
  before_filter :hack_params_for_establishments_nested_resources, :only => [ :create, :update ]
  
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
      flash[:notice] = "Le client a été supprimé avec succès"
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
    def hack_params_for_establishments_nested_resources

      if params[:customer][:establishment_attributes]
        params[:customer][:establishment_attributes].each_with_index do |establishment_attributes, index|
          
          # hack for addresses
          establishment_attributes[:address_attributes] = params[:establishment][:address_attributes][index] if params[:establishment][:address_attributes]
          
          # hack for has_number
          establishment_attributes[:fax_attributes]   = params[:establishment][:fax_attributes][index]   if params[:establishment][:fax_attributes]
          establishment_attributes[:phone_attributes] = params[:establishment][:phone_attributes][index] if params[:establishment][:phone_attributes]
          
          # hack for  has_contacts
          if params[:establishment][:contact_attributes]
            contact_attributes = params[:establishment][:contact_attributes].select {|n| establishment_attributes[:id] == n[:establishment_id]}
            establishment_attributes[:contact_attributes] = clean_params(contact_attributes, :establishment_id)
          
            # hack for contact's numbers
            if params[:contact] && params[:contact][:number_attributes]
              establishment_attributes[:contact_attributes].each_with_index do |contact_attributes, index|
                number_attributes = params[:contact][:number_attributes].select {|n| contact_attributes[:id] == n[:has_number_id]}
                contact_attributes[:number_attributes] = clean_params(number_attributes, :has_number_id)
              end
              contact_attributes[:id] = nil if is_a_fake_id?(contact_attributes[:id])                # remove fake ids used to recover new_record's numbers
            end
            remove_fake_ids(establishment_attributes[:contact_attributes])
            # remove fake ids after managing numbers because even if the fake ids are linked to them
            # if there 's no numbers the fake ids still be there so it will raise an error into at the model level
          end
          
        end
        params.delete(:establishment)
      end

      if params[:customer][:head_office_attributes]
        head_office_attributes = params[:customer][:head_office_attributes].first # there's only one head_office
        
        # hack for addresses
        head_office_attributes[:address_attributes] = params[:head_office][:address_attributes].first if params[:head_office][:address_attributes]
          
        # hack for has_number
        head_office_attributes[:fax_attributes]   = params[:head_office][:fax_attributes].first   if params[:head_office][:fax_attributes]
        head_office_attributes[:phone_attributes] = params[:head_office][:phone_attributes].first if params[:head_office][:phone_attributes]
        
        # hack for has_contacts
        if params[:head_office][:contact_attributes]
          head_office_attributes[:contact_attributes] = clean_params(params[:head_office][:contact_attributes], :head_office_id)
          
          # hack for contact's numbers
          if params[:contact] && params[:contact][:number_attributes]
            head_office_attributes[:contact_attributes].each_with_index do |contact_attributes, index|
              number_attributes                      = params[:contact][:number_attributes].select {|n| contact_attributes[:id] == n[:has_number_id]}
              contact_attributes[:number_attributes] = clean_params(number_attributes, :has_number_id)
            end
          end
          remove_fake_ids(head_office_attributes[:contact_attributes])
        end
        
        params.delete(:head_office)
      end
    end
  
    # Method used to remove some keys that mustn't be passed to the model
    #
    def clean_params(array, key)
      array.each do |hash|
        hash.delete(key)
      end
      array
    end
    
    # Method to find if the id passed as argument is a fake one
    # used to retrieve new_record's numbers
    #
    def is_a_fake_id?(id)
      /new_record_([0-9])*/.match(id)
    end
    
    # Method to remove fake ids that become useless after params hack
    #
    def remove_fake_ids(collection)
      collection.each do |element|
        element[:id] = nil if is_a_fake_id?(element[:id])
      end
    end
end
