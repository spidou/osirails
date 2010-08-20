class StockFlowsController < ApplicationController
  helper :stock_flows
  
  before_filter :define_stock_flow_type
  
  before_filter :find_supply,         :only => :new
  before_filter :define_supply_type,  :only => [ :new, :create ]
  before_filter :find_supplies,       :only => [ :new, :create ]

  # GET /stock_inputs/index
  # GET /stock_inputs/index?supply_type=:supply_type
  # GET /stock_outputs/index
  # GET /stock_outputs/index?supply_type=:supply_type
  def index
    paginate_options = { :page => params[:page], :per_page => StockFlow::STOCK_FLOWS_PER_PAGE }
    
    if params[:supply_type]
      if params[:supply_type] == "Commodity"
        @stock_flows = @stock_flow_type.of_commodities.paginate(paginate_options)
      elsif params[:supply_type] == "Consumable"
        @stock_flows = @stock_flow_type.of_consumables.paginate(paginate_options)
      else
        return error_access_page(400)
      end
    else
      @stock_flows = @stock_flow_type.all(:order => "stock_flows.created_at DESC").paginate(paginate_options)
    end
  end

  # GET /stock_inputs/new
  # GET /stock_inputs/new?supply_type=:supply_type
  # GET /stock_inputs/new?supply_id=:supply_id
  # GET /stock_outputs/new
  # GET /stock_outputs/new?supply_type=:supply_type
  # GET /stock_outputs/new?supply_id=:supply_id
  def new
    @stock_flow = @stock_flow_type.new
    if @supply
      @stock_flow.attributes = { :supply_id => @supply.id, :unit_price => @supply.higher_unit_price }
    end
  end

  # POST /stock_inputs
  # POST /stock_outputs
  def create
    @stock_flow = @stock_flow_type.new(params[@stock_flow_type.name.underscore.to_sym])
    if @stock_flow.save
      flash[:notice] = "L'entrée de stock a été effectuée avec succès"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  private
    def find_supply
      @supply = Supply.find_by_id(params[:supply_id])
    end
    
    def define_supply_type
      return error_access_page(400) unless ["Commodity", "Consumable", nil].include?(params[:supply_type])
      @supply_type = params[:supply_type] ? params[:supply_type].constantize : nil
      
      if @supply_type.nil? and @supply.nil?
        return error_access_page(400)
      else
        @supply_type ||= @supply.class
      end
    end
    
    def find_supplies
      @supplies = @supply_type.was_enabled_at
    end
end
