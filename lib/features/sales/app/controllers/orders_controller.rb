class OrdersController < ApplicationController
  def index
    
  end
  
  def new
    
  end

  def show
    # TODO Faire des redirects vers le bon controleur correspondant au step en cours. Puis a l'intérieur de ce controller, si il y'a un params[:step] faire un render partial du step demander.
    @order = Order.find(params[:id])
    params[:step] ||= @order.step.name
    begin
    render_component :controller => params[:step], :action => 'show', :id => params[:id]
    rescue NameError
      error_access_page(404)
    end
  end
  
  def edit
    
  end
  
  def create
    
  end
  
  def update
    
  end
end