module PaymentStepHelper
  
  def display_invoices_for_payment(order)
    invoices = (order.invoices.awaiting_payment + order.invoices.paid)
    if invoices.empty?
      content_tag(:p, "Aucune facture n'a été trouvée")
    else
      render :partial => 'invoices/invoices_list', :object => invoices
    end
  end
  
end
