class OrdersController < ApplicationController
  # Callbacks
  before_filter :check, :except => [:index, :new, :create]
  
  def index
    
  end
  
  def new
    @order = Order.new
  end

  def show
    
  end
  
  def edit
    
  end
  
  def create
    if params[:order][:order_type]
      params[:order][:order_type] = OrderType.find(params[:order][:order_type])
    end
    
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "Dossier crée avec succés"
      redirect_to orders_path(@order)
    else
      flash[:error] = "Erreur lors de la création du dossier"
      redirect_to prospectives_path
    end
  end
  
  def update
    @order = Order.update_attributes(params[:order])
    if @order
      flash[:notice] = "Dossier modifié avec succés"
      redirect_to order_path(@order)
    else
      flash[:error] = "Erreur lors de la mise à jour du dossier"
    end
  end
  
  private
  
  def check
    @order = Order.find(params[:id])
  end
end