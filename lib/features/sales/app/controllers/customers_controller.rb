require_dependency 'lib/features/thirds/app/controllers/customers_controller'

class CustomersController
  helper :address
  
  after_filter :detect_request_for_order_creation, :only => :new
  after_filter :redirect_to_new_order, :only => :create
  
  def auto_complete_for_customer_name
    @keyword = params[:customer] ? params[:customer][:name] : ""
    @items = Customer.find(:all, { :include     => :establishments,
                                   :conditions  => [ "thirds.name like ? or establishments.name like ?", "%#{@keyword}%", "%#{@keyword}%"],
                                   :order       => "thirds.name ASC",
                                   :limit       => 15 })
    render :inline => "<%= custom_auto_complete_result(@items, 'name', @keyword) %>"
  end
  
  private
    def detect_request_for_order_creation
      session[:request_for_order_creation] = params[:order_request] === "1" ? true : false
    end
    
    def redirect_to_new_order
      if @customer.errors.empty? and session[:request_for_order_creation]
        session[:request_for_order_creation] = nil
        erase_redirect_results
        redirect_to( new_order_path(:customer_id => @customer.id) )
      end
    end
end
