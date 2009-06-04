class CustomersController < ApplicationController
  helper :thirds, :establishments, :contacts, :documents
  
  before_filter :hack_params_for_establishments_addresses, :only => [ :create, :update ]
  
  # GET /customers
  # GET /customers.xml
  def index
    if Customer.can_list?(current_user)
      @customers = Customer.activates
    else
      error_access_page(403)
    end
  end
  
  # GET /customers/1
  # GET /customers/1.xml
  def show
    if Customer.can_view?(current_user)
      @customer = Customer.find(params[:id])
      
      # needed collections
      @contacts = @customer.contacts
#      @establishments = @customer.activated_establishments
#      @documents = @customer.documents
    else
      error_access_page(403)
    end
  end
  
  # GET /customers/new
  # GET /customers/new.xml
  def new
    if Customer.can_add?(current_user)
      @customer = Customer.new
    else
      error_access_page(403)
    end
  end

  # POST /customers
  # POST /customers.xml
  def create
    if Customer.can_add?(current_user)
      @customer = Customer.new(params[:customer])
      if @customer.save
        flash[:notice] = "Client ajout&eacute; avec succ&egrave;s"
        redirect_to(customer_path(@customer))
      else
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end

  # GET /customers/1/edit
  def edit
    if Customer.can_edit?(current_user)
      @customer = Customer.find(params[:id])
#      @establishments = @customer.activated_establishments
      @contacts = @customer.contacts
      @documents = @customer.documents
      @activity_sector = @customer.activity_sector.name unless @customer.activity_sector.nil?
      
      respond_to do |format|
#        params[:page] ||= 1
        params[:type] == "popup" ? format.html {render :layout => 'popup'} : format.html
        @javascript = "<script langage='javascript'> parent.document.getElementById('testpage').innerHTML = document.getElementById('testpage').innerHTML</script>"
        format.js { render( :layout => false, :partial => 'documents/edit_partial', :locals => {:document => (Document.find(params[:document_id]) unless params[:document_id].nil?), :javascript => @javascript})}
      end
    
    else
      error_access_page(403)
    end    
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    if Customer.can_edit?(current_user)
      @customer = Customer.find(params[:id])
      if @customer.update_attributes(params[:customer])
        flash[:notice] = "Le client a été modifié avec succès"
        redirect_to customer_path(@customer)
      else
        render :action => 'edit'
      end
    else
      error_access_page(403)
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    if Customer.can_delete?(current_user)
      @customer = Customer.find(params[:id])
      @customer.activated = false
      if @customer.save
        redirect_to(customers_path)
      else
        flash[:error] = "Une erreur est survenu lors de la suppression du contact"
        redirect_to :back 
      end
    else
      error_access_page(403)
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
