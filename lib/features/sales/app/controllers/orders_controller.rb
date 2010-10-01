class OrdersController < ApplicationController
  helper :contacts, :ship_to_addresses, :numbers, :address
  
  before_filter :load_collections
  before_filter :hack_params_for_ship_to_address_addresses, :only => [ :create, :update ]

  acts_as_step_controller :sham => true, :step_name => :commercial_step
  
  def index
    redirect_to :action => :new
  end
  
  # GET /orders/1
  # GET /orders/1.svg
  def show
    respond_to do |format|
      format.html {
        if @order.current_step
          redirection = send(@order.current_step.original_step.path, @order)
        else
          redirection = order_informations_path(@order)
        end
        flash.keep
        redirect_to redirection
      }
      format.svg {
        if params[:for]
          render :partial => 'mini_order', :object => @order
        else
          render :partial => 'order', :object => @order
        end
      }
    end
  end
  
  # GET /orders/new
  def new
    @order = Order.new
    @order.creator = current_user
    if params[:customer_id] # this is the second step of the order creation
      begin
        @order.customer = Customer.find(params[:customer_id])
        @order.order_contact = @order.customer_contacts.first
        @order.build_bill_to_address(@order.customer.bill_to_address.attributes)
      rescue ActiveRecord::RecordNotFound => e
        flash.now[:error] = "Le client n'a pas été trouvé, merci de réessayer."
      end
    end
  end
  
  # POST /orders
  def create
    @order = Order.new(:customer_id => params[:order][:customer_id]) # establishment_attributes needs customer_id is set before all other attributes
    @order.attributes = params[:order]
    @order.creator = current_user
    if @order.save
      flash[:notice] = "Dossier créé avec succès"
      redirect_to order_informations_path(@order)
    else
      render :action => "new"
    end
  end
  
  # GET /orders/1/edit
  def edit
  end
  
  # PUT /orders/1
  def update
    if @order.update_attributes(params[:order])
      flash[:notice] = "Dossier modifié avec succés"
      redirect_to order_informations_path(@order)
    else
      render :action => 'edit'
    end
  end
  
  private
    def load_collections
      @commercials = Employee.all
      @society_activity_sectors = SocietyActivitySector.all
      @order_types = OrderType.all
    end
    
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_ship_to_address_addresses
      if params[:order]
        if params[:order][:establishment_attributes] and params[:establishment] and params[:establishment][:address_attributes]
          params[:order][:establishment_attributes].each_with_index do |establishment_attributes, index|
            establishment_attributes[:address_attributes] = params[:establishment][:address_attributes][index]
          end
          params.delete(:establishment)
        end
        
        # hack for has_contact :order_contact
        if params[:order][:order_contact_attributes] and params[:contact]
          params[:order][:order_contact_attributes][:number_attributes] = params[:contact][:number_attributes]
        end
        params.delete(:contact)
      end
    end
end
