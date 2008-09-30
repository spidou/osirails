class OrdersController < ApplicationController
  # Callbacks
  before_filter :check, :except => [:index, :new, :create, :auto_complete_for_employee_fullname]
  
  method_permission :add => ['auto_complete_for_employee_first_name'], :edit => ['auto_complete_for_employee_first_name']
  
  def auto_complete_for_employee_fullname
    all_employees = Employee.find(:all)
    fullname = params[:employee][:fullname].downcase
    @employees = []
    all_employees.each do |e|
      @employees << e if !e.first_name.downcase.grep(/#{fullname}/).empty? || !e.last_name.downcase.grep(/#{fullname}/).empty?
    end
    render :partial => 'auto_complete_for_employee_fullname'
  end
  
  def index
    
  end
  
  def new
    @order = Order.new
    if params[:customer_id]
      @customer = Customer.find(params[:customer_id])
    elsif params[:customer]
      @customer = Customer.find_by_name(params[:customer][:third][:name])
    end
    flash[:error] = "Client non trouvé" if (@customer.nil? && params[:customer])
  end

  def show
    redirect_to order_path(@order) + '/' + @order.step.name[5..-1].downcase
  end
  
  def edit
    
  end
  
  def create
    @order = Order.new(@parameters)
    if @order.save
      flash[:notice] = "Dossier crée avec succés"
      redirect_to order_path(@order)
    else
      flash[:error] = "Erreur lors de la création du dossier"
      redirect_to prospectives_path
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