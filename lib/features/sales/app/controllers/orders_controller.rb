class OrdersController < ApplicationController
  # Callbacks
  before_filter :check, :except => [:index, :new, :create, :auto_complete_for_employee_fullname]
  
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
  
  def index
    
  end
  
  def new
    @current_order_step = "commercial"
    @order = Order.new
    #raise params.inspect
    
    if params[:customer_id] or params[:new_customer_id] # this is the second step of the order creation
      customer_id = params[:customer_id] || params[:new_customer_id]
      
      begin
        @customer = Customer.find(customer_id)
        @commercials = Employee.find(:all)
        @order_types = OrderType.find(:all)
        @contacts = @customer.contacts_all
      rescue
        flash.now[:error] = "Le client n'a pas été trouvé. Veuillez réessayer."
      end
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to order_path(@order) + '/' + @order.step.name[5..-1].downcase }
      format.svg {render :partial => 'order' }
    end
  end
  
  def edit
    @commercials = Employee.find(:all)
    @order_types = OrderType.find(:all)
    @contacts = @customer.contacts_all
  end
  
  def create
    #raise params[:order].inspect
    order_type = OrderType.find(params[:order].delete(:order_type))
    
    @order = Order.new(params[:order])
    @order.order_type = 
    if @order.save
      flash[:notice] = "Dossier crée avec succés"
      redirect_to order_path(@order)
    else # error
      ## variables for the form
      @customer = @order.customer
      @commercials = Employee.find(:all)
      @order_types = OrderType.find(:all)
      @contacts = @customer.contacts_all
      
      # render the new action
      render :action => "new"
    end
  end
  
  def update
    if @order.update_attributes(@parameters)
      flash[:notice] = "Dossier modifié avec succés"
      redirect_to order_path(@order)
    else
      flash[:error] = "Erreur lors de la mise à jour du dossier"
    end
  end
  
  private
  
  def check
    @order = Order.find(params[:id])
    OrderLog.set(@order, current_user, params) # Manage logs
    @current_order_step = @order.step.first_parent.name[5..-1]
    @customer = @order.customer
    
    if params[:order]
      @parameters = {}
      @parameters.update(params[:order])
      @parameters[:commercial] = Employee.find(params[:employee_id])
      @parameters[:order_type] = OrderType.find(params[:order][:order_type])
      @parameters[:customer] = Customer.find(params[:order][:customer])
    end
  end
end