module PressProofsHelper
  def display_press_proofs_dropbox
    html = "<div id='press_proofs_drop_box'></div>"
  end
  
  # TODO call one method by 
  def action_links(order, press_proof)
    html  = confirm_order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += send_to_customer_order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += sign_order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += revoke_order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += cancel_order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += edit_order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "")
    html += order_commercial_step_press_proof_step_press_proof_link(order, press_proof, :link_text => "", :method => :delete, :confirm => "Êtes vous sûr?")
  end
  
#  def display_press_proofs_list(order)
#    html  = ""
#    order.products.each do |product|
#      next if product.press_proofs.empty?
#      html += "<tr>"
#      html += "<td>#{ product.description }</td>"
#      html += "<td>#{ product.quantity }</td>"
#      
#      product.press_proofs.each do |press_proof|
#        html += "<td>#{ press_proofs.confirmed_on.humanize unless press_proofs.confirmed_on.nil? }</td>"
#        html += "<td>#{ press_proofs.product.description }</td>"
#        
##        press_proof.mockups.each do |mockup|
##          html += "<td>#{ mockup.type }</td>"
##          html += "<td>#{ mockup.description }</td>"
##          html += "<td>#{ press_proofs.product.description }</td>"
##        end
#        
#        html += "<td>#{ press_proofs.internal_actor.fullname }</td>"
#        html += "<td>#{ press_proofs.sended_on.humanize unless press_proofs.sended_on.nil? }</td>"
#        html += "<td>#{ press_proofs.sended_on.humanize unless press_proofs.signed_on.nil? }</td>"
#        html += "<td>#{  }</td>" # TODO manage relance
#        html += "<td>#{ actions_links(order, press_proof ) }</td>"
#        
#      end
#      html += "</tr>"
#    end
#    html
#  end
  
  def display_press_proofs_buttons
  end
end
