class OrdersController < ApplicationController
  before_filter :load_collections
  
#  method_permission :add => ['auto_complete_for_employee_first_name'], :edit => ['auto_complete_for_employee_first_name']
  
#  def auto_complete_for_employee_fullname
#    all_employees = Employee.find(:all)
#    fullname = params[:employee][:fullname].downcase
#    @employees = []
#    all_employees.each do |e|
#      @employees << e if !e.first_name.downcase.grep(/#{fullname}/).empty? || !e.last_name.downcase.grep(/#{fullname}/).empty?
#    end
#    render :partial => 'auto_complete_for_employee_fullname'
#  end

  acts_as_step_controller :sham => true, :step_name => "step_commercial"
  
  def show
    respond_to do |format|
      format.html {
        if @order.current_step
          redirection = send("order_step_#{@order.current_step.path}_path", @order)
        else
          redirection = order_informations_path(@order)
        end
        redirect_to redirection
      }
      format.svg {
        case params[:for]
        when 'step'
          render :partial => 'mini_order', :locals => { :children_list => @order.first_level_steps }
        when 'understep'
          render :partial => 'mini_order', :locals => { :children_list => @order.child.children_steps }
        else
          render :partial => 'order'
        end
      }
    end
  end
  
  def new
    @order = Order.new
    if params[:customer_id] # this is the second step of the order creation
      begin
        @order.customer = Customer.find(params[:customer_id])
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
      redirect_to order_informations_path(@order)
    else
      @contacts = @order.customer.contacts_all
      render :action => "new"
    end
  end
  
  def edit
    @contacts = @order.customer.contacts_all
  end
  
  def update
    params[:order][:contact_ids] ||= []
    if @order.update_attributes(params[:order])
      flash[:notice] = "Dossier modifié avec succés"
      redirect_to order_path(@order)
    else
      flash[:error] = "Erreur lors de la mise à jour du dossier"
    end
  end
  
  private
    def load_collections
      @commercials = Employee.find(:all)
      @order_types = OrderType.find(:all)
    end
end
