class OrdersController < ApplicationController
  # Callbacks
  before_filter :load_collections, :only => [:new, :create, :edit, :update]
  after_filter :check, :except => [:index, :new, :create, :auto_complete_for_employee_fullname]
  
  method_permission :add => ['auto_complete_for_employee_first_name'], :edit => ['auto_complete_for_employee_first_name']
  
#  def auto_complete_for_employee_fullname
#    all_employees = Employee.find(:all)
#    fullname = params[:employee][:fullname].downcase
#    @employees = []
#    all_employees.each do |e|
#      @employees << e if !e.first_name.downcase.grep(/#{fullname}/).empty? || !e.last_name.downcase.grep(/#{fullname}/).empty?
#    end
#    render :partial => 'auto_complete_for_employee_fullname'
#  end
  
  def show
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html { redirect_to order_path(@order) + '/' + @order.step.name[5..-1].downcase }
      format.svg {render :partial => 'order' }
    end
  end
  
  def new
    @current_order_step = "commercial"
    @order = Order.new
    
    if params[:customer_id] or params[:new_customer_id] # this is the second step of the order creation
      customer_id = params[:customer_id] || params[:new_customer_id]
      
      begin
        @order.customer = Customer.find(customer_id)
        @contacts = @order.customer.contacts_all
      rescue Exception => e
        flash.now[:error] = "Le client n'a pas été trouvé. Veuillez réessayer. Erreur : #{e.message}"
      end
    end
  end
  
  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "Dossier crée avec succès"
      redirect_to order_path(@order)
    else # error
      @contacts = @order.customer.contacts_all
      # render the new action
      render :action => "new"
    end
  end
  
  def edit
    @order = Order.find(params[:id])
    @contacts = @order.customer.contacts_all
  end
  
  def update
    params[:order][:contact_ids] ||= []
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      flash[:notice] = "Dossier modifié avec succés"
      redirect_to order_path(@order)
    else
      flash[:error] = "Erreur lors de la mise à jour du dossier"
    end
  end
  
  private
  
    def check
      OrderLog.set(@order, current_user, params) # Manage logs
      @current_order_step = @order.step.first_parent.name[5..-1]
#      @customer = @order.customer
#
#      if params[:order]
#        @parameters = {}
#        @parameters.update(params[:order])
#        @parameters[:commercial] = Employee.find(params[:employee_id])
#        @parameters[:order_type] = OrderType.find(params[:order][:order_type])
#        @parameters[:customer] = Customer.find(params[:order][:customer])
#      end
    end
    
    def load_collections
      @commercials = Employee.find(:all)
      @order_types = OrderType.find(:all)
    end
end