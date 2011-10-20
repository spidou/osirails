class QuoteManagementController < ApplicationController
  helper :orders, :quotes
  query :quotes
  
  # GET /quote_management
  def index
    build_query_for(:quote_management_index)
  end
end
