class QueriesController < ApplicationController
  attr_accessor :return_uri
  before_filter :prepare_variables
  before_filter :prepare_params, :only => [:edit, :new, :update, :create]
  
  # GET /queries/:id/edit
  def edit
    @query = Query.find(params[:id])
    params[:query].each {|k,v| @query.send("#{ k }=",v)} if params[:query] 
    @return_uri = params[:return_uri] + "?query_id=#{ @query.id }"
  end
  
  # PUT /queries/:id
  def update
    @query = Query.find(params[:id])
    @query.order = get_order(params[:query].delete(:order)) 
    
    if @query.update_attributes(params[:query])
      flash[:notice] = "La requête a été modifiée avec succés"
      redirect_to params[:return_uri] + "?query_id=#{ @query.id }"
    else
      @return_uri = params[:return_uri]
      render :action => 'edit'
    end
  end
  
  # GET /queries/new
  def new
    @query = Query.new(params[:query])
    @return_uri = params[:return_uri]
  end
  
  # POST /queries
  def create
    @query = Query.new(params[:query])
    @query.creator = current_user
    @query.order = get_order(params[:query].delete(:order)) 
    
    if @query.save
      flash[:notice] = "La requête a été créée avec succés"
      redirect_to params[:return_uri] + "?query_id=#{ @query.id }"
    else
      @return_uri = params[:return_uri]
      render :action => 'new'
    end
  end
  
  # DELETE /queries/:id
  def destroy
    redirect_to(params[:return_uri]) && Query.find(params[:id]).destroy
  end

  private
  
    def get_order(params_order)
      return [] if params_order.nil?
      params_order.map {|n| "#{ n[:attribute] }:#{ n[:direction] }"}
    end
    
    def prepare_params
      criteria = {}
      if params[:criteria]
        params[:criteria].each do |attribute, options|
          options[:value].each_with_index do |value, index|
            criteria[attribute] ||= []
            criteria[attribute] << {:action => options[:action].at(index), :value => value}
          end
        end
      end
      params[:query][:criteria] = criteria
    end
    
    def prepare_variables
      return unless params[:query]
      @page_name = params[:query][:page_name].to_s
      @page_configuration  = HasSearchIndex::HTML_PAGES_OPTIONS[@page_name.to_sym]
      @organized_filters ||= HasSearchIndex.organized_filters(@page_configuration[:filters], @page_configuration[:model])
      
      @data_types = {@page_name => {}}
      @page_configuration[:filters].each do |filter|
        attribute = filter.is_a?(Hash) ? filter.values.first : filter
        @data_types[@page_name][attribute] = HasSearchIndex.get_nested_attribute_type(@page_configuration[:model], filter)
      end
    end
end
