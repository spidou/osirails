module PaymentsHelper
  
  def display_payments_list_for(due_date)
    id = due_date.was_paid? ? '' : " id=\"new_payments_for_due_date_#{due_date.id}\""
    
    html = "<div class=\"payments\"#{id}>"
    html << render(:partial => 'payments/payment', :collection => due_date.payments, :locals => { :due_date => due_date }) unless due_date.payments.empty?
    html << '</div>'
  end
  
  def display_payment_add_link(due_date)
    link_to_function "Nouveau règlement" do |page|
      div_id = "new_payments_for_due_date_#{due_date.id}"
      page.insert_html :bottom, div_id, :partial  => 'payments/payment',
                                        :object   => due_date.payments.build(:paid_on => Date.today),
                                        :locals   => { :due_date => due_date }
      last_payment = page[div_id].select('.payment').last
      last_payment.show
      last_payment.visual_effect :highlight
    end
  end
  
  def display_payment_remove_link
    content_tag( :p, link_to_function("Supprimer", "this.up('.payment').remove()") )
  end
end
