class QuoteManagementController < ApplicationController
  helper :orders, :quotes
  
  # GET /quote_management
  def index
    @quotes = Quote.unsigned
  end
end
