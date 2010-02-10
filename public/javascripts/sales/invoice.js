function update_deposit_amount(element) {
  total = parseFloat($('signed_quote_total_with_taxes').innerHTML)
  $('invoice_deposit_amount').value = Math.round(total * parseFloat(element.value)) / 100
  
  update_deposit_amount_without_taxes($('invoice_deposit_amount'))
}

function update_deposit_amount_without_taxes(element) {
  deposit_vat = parseFloat($('invoice_deposit_vat').value)
  deposit_amount = parseFloat(element.value)
  deposit_amount_without_taxes = deposit_amount / ( 1 + ( deposit_vat / 100 ) )
  $('deposit_amount_without_taxes').update(Math.round(deposit_amount_without_taxes*100)/100)
  
  check_values_of_total_and_due_dates()
}

function check_values_of_total_and_due_dates() {
  sum_net_to_paid = 0
  $('due_dates_list').down('tbody').select('tr:not([id="due_date_model"])').each(function(element) {
    input = element.down('.due_date_net_to_paid_input')
    sum_net_to_paid += parseFloat(input.value)
  });
  
  sum_net_to_paid = Math.round(sum_net_to_paid*100)/100
  
  total_invoice = parseFloat($('invoice_deposit_amount').value)
  
  if (sum_net_to_paid != total_invoice) {
    $('due_date_amounts_notification').removeClassName('hidden')
  } else {
    $('due_date_amounts_notification').addClassName('hidden')
  }
}

function refresh_due_dates() {
  total_invoice = parseFloat($('invoice_deposit_amount').value)
  
  sum_net_to_paid_without_balance = 0
  $('due_dates_list').down('tbody').select('tr:not([id="due_date_model"])').each(function(element) {
    input = element.down('.due_date_net_to_paid_input')
    if (input.type != 'hidden') { sum_net_to_paid_without_balance += parseFloat(input.value) }
  });
  
  balance = total_invoice - sum_net_to_paid_without_balance
  balance = Math.round(balance*100)/100
  
  last_due_date = $('last_due_date')
  input = last_due_date.down('.due_date_net_to_paid_input')
  span = last_due_date.down('.balance_due_date_net_to_paid')
  
  input.value = balance
  span.update(balance)
  new Effect.Highlight(last_due_date, { startcolor: "#ffff00", endcolor: "#ffffff", restorecolor: "#ffffff" })
  
  if (balance < 0)
    alert("Attention !! Le montant des premières échéances sont supérieurs au montant total de la facture. C'est pourquoi vous obtenez un solde négatif.")
  
  check_values_of_total_and_due_dates()
}

due_date_label = null

function update_due_dates(select_element) {
  new_quantity = select_element.value
  old_quantity = $('due_dates_list').down('tbody').select('tr').length - 1
  
  total_invoice = parseFloat($('invoice_deposit_amount').value)
  
  if (due_date_label == null) {
    due_date_label = $('due_date_model').down('td.due_date_label').innerHTML
  }
  
  diff = new_quantity - old_quantity
  if (diff == 0) { alert("Une erreur innattendue est survenue. Merci de contacter votre administrateur réseau en lui expliquant les actions que vous avez fait avant d'obtenir cette erreur."); return }
  
  action = diff > 0 ? 'add' : 'remove'
  diff = Math.abs(diff)
  
  if (action == 'add') {
    
    for (i = 0; i < diff; i++) {
      identifier = parseInt(old_quantity) + i
      
      new_line = $('due_date_model').cloneNode(true)
      $('last_due_date').insert({before: new_line})
      
      new_line.removeAttribute('id')
      new_line.select('input[disabled="disabled"]').each(function(element) {
        element.removeAttribute('disabled')
      })
      new_line.select('.due_date_counter').first().update(identifier)
      new_line.select('.due_date_label').first().update( due_date_label + ' ' + identifier )
    }
    
  } else if (action == 'remove') {
    
    count = 1
    $('due_dates_list').down('tbody').select('tr:not([id="due_date_model"])').each(function(element) {
      if (count >= new_quantity && count < old_quantity) {
        if (element.down('.due_date_id') && element.down('.due_date_id').value > 0) {
          element.down('.should_destroy').value = '1'
          copy = element.cloneNode(true)
          $('due_dates_to_remove').insert(copy)
        }
        element.remove()
      }
      count++
    })
    
  }
  
  date = new Date()
  due_date_net_to_paid = parseInt(total_invoice / new_quantity)
  
  $('due_dates_list').down('tbody').select('tr:not([id="due_date_model"])').each(function(element) {
    if (element.down('.due_date_date_input').value == '') {
      //element.down('.due_date_date_input').value = date.strftime("%Y-%m-%d") // this is deactivated because we have to fix the bug in which the balance due_date have a 'wrong' date when we add 1 or more due_dates between the before-last and the last due_date
    }
    
    element.down('.due_date_net_to_paid_input').value = due_date_net_to_paid
    
    if (element.id == 'last_due_date') {
      gap = total_invoice - ( due_date_net_to_paid * new_quantity )
      gap = Math.round(gap*100)/100
      balance = due_date_net_to_paid + gap
      
      element.down('.balance_due_date_net_to_paid').update(balance)
      element.down('.due_date_counter').update(new_quantity)
    }
    
    date.setMonth(date.getMonth() + 1) // next due_date for next month
  })
  
  refresh_due_dates()
  new Effect.Highlight($('due_dates_list'), { startcolor: "#ffff00", endcolor: "#ffffff", restorecolor: "#ffffff" })
}

original_value_for_toggle_payment_details = null
function toggle_payment_details(element) {
  div = element.up('.payment').down('.payment_details')
  div.toggle()
  
  if (div.visible()) {
    original_value_for_toggle_payment_details = element.innerHTML
    element.update("Réduire")
  } else {
    element.update(original_value_for_toggle_payment_details)
  }
}

function toggle_disable_of_select_number_of_due_dates() {
  select_factor = $('invoice_factor_id')
  select_number_due_dates = $('number_of_due_dates')
  
  if (select_factor.value == '') { // if we choose NO factor
    select_number_due_dates.removeAttribute('disabled')
  } else if (select_number_due_dates.value == 1) { // else if we choose a factor, and if there is only 1 due_date presently selected
    select_number_due_dates.setAttribute('disabled', 'disabled')
  }
}
