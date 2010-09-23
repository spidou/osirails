class InvoiceManagementsController < ApplicationController
  include AdjustPdf
  helper :orders, :contacts, :payments, :adjustments, :numbers, :invoices
  
  # GET /sales/invoice_managements/
  def index
    @invoices = Invoice.all
  end
end
