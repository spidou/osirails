class OrdersController < ApplicationController
  helper :contacts
  
  before_filter :load_collections

  acts_as_step_controller :sham => true, :step_name => :commercial_step
  
  def index
    redirect_to :action => :new
  end
  
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
  
  def new
    @order = Order.new
    if params[:customer_id] # this is the second step of the order creation
      begin
        @order.customer = Customer.find(params[:customer_id])
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
      render :action => "new"
    end
  end
  
  def edit
  end
  
  def update
    params[:order][:contact_ids] ||= []
    if @order.update_attributes(params[:order])
      flash[:notice] = "Dossier modifié avec succés"
      redirect_to order_informations_path(@order)
    else
      render :action => 'edit'
    end
  end
  
  private
    def load_collections
      @commercials = Employee.find(:all)
      @order_types = OrderType.find(:all)
    end
end
