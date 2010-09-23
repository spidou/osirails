class QuoteManagementsController < ApplicationController
  include AdjustPdf
  helper :orders, :contacts, :numbers, :quotes
  
  # GET /sales/quote_managements/
  def index
    @quotes = Quote.all
  end
end
