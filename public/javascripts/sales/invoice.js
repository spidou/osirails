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

function get_invoice_net_to_paid() {
  if ($('invoice_deposit_amount')) {
    return parseFloat($('invoice_deposit_amount').value) // case of deposit invoice
  } else {
    return parseFloat($('invoice_net_to_paid').innerHTML.strip()) // case of other type of invoice
  }
}

function check_values_of_total_and_due_dates() {
  sum_net_to_paid = 0
  $('due_dates_list').down('tbody').select('tr:not([id="due_date_model"])').each(function(element) {
    input = element.down('.due_date_net_to_paid_input')
    sum_net_to_paid += parseFloat(input.value)
  });
  
  sum_net_to_paid = Math.round(sum_net_to_paid*100)/100
  
  total_invoice = get_invoice_net_to_paid()
  
  if (sum_net_to_paid != total_invoice) {
    $('due_date_amounts_notification').appear()
    $('due_dates_list').up('.root_nav').down('.invoice_due_dates_payments').addClassName('warning')
  } else {
    $('due_date_amounts_notification').fade()
    $('due_dates_list').up('.root_nav').down('.invoice_due_dates_payments').removeClassName('warning')
  }
}

function refresh_due_dates() {
  total_invoice = get_invoice_net_to_paid()
  
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
  new Effect.Highlight(last_due_date, {afterFinish: function(){ last_due_date.setStyle({backgroundColor: ''}) }}) // reset background-color value to be sure to restore orginal value from CSS
  
  if (balance < 0 && sum_net_to_paid_without_balance > 0)
    alert("Attention !! Le montant des premières échéances sont supérieurs au montant total de la facture. C'est pourquoi vous obtenez un solde négatif.")
  
  check_values_of_total_and_due_dates()
}

due_date_label = null

function update_due_dates(select_element) {
  new_quantity = select_element.value
  old_quantity = $('due_dates_list').down('tbody').select('tr').length - 1
  
  total_invoice = get_invoice_net_to_paid()
  
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
  //new Effect.Highlight($('due_dates_list'), { startcolor: "#ffff00", endcolor: "#ffffff", restorecolor: "#ffffff" })
  new Effect.Highlight($('due_dates_list'), {afterFinish: function(){ $('due_dates_list').setStyle({backgroundColor: ''}) }})
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

function update_invoice_items(checkbox, url_prefix) {
  selected_items = checkbox.up('.collection').select('input[type=checkbox]').collect(function(input){
    if (input.checked) { return input.value }
  })
  selected_items = selected_items.compact()
  
  form_buttons = checkbox.up('form').select('input[type=submit]')
  
  url = url_prefix + '/' + selected_items;
  
  new Ajax.Request(url, {
    method: 'get',
    onLoading: function() {
      $('invoice_items_ajax_loading').appear();
      form_buttons.each(function(button){
        button.disable()
      });
    },
    onLoaded: function() {
      $('invoice_items_ajax_loading').fade();
      form_buttons.each(function(button){
        button.enable()
      });
    },
    onFailure: function(error) {
      alert('Oops, une erreur inattendue est survenue. Merci de contacter votre administrateur.')
    },
    onSuccess: function(transport) {
      //nothing to do here, see in .rjs called file
    }
  });
}

function add_free_item() {
  foot = $('invoice_items_foot')
  body = $('invoice_items_body')
  
  new_line = foot.down('.invoice_item').cloneNode(true);
  body.insert( {'bottom' : new_line } );
  
  last_line = body.childElements().last();
  last_line.down('.should_destroy').removeAttribute('value');
  last_line.removeAttribute('style');
  new Effect.Highlight(last_line, {afterFinish: function(){ last_line.setStyle({backgroundColor: ''}) }})
  
  update_up_down_links($('invoice_items_body')); //defined in sales.js
}

function remove_free_item(element) {
  item = element.up('tr.invoice_item')
  
  if (parseInt(item.down('.invoice_item_id').value) > 0) {
    item.down('.should_destroy').value = 1;
    item.hide();
  } else {
    item.remove();
  }
  
  update_up_down_links($('invoice_items_body')); //defined in sales.js
  update_aggregates();
}

function calculate(tr) {
  var unit_price  = parseFloat(tr.down('.input_unit_price').value)
  var quantity    = parseFloat(tr.down('.input_quantity').value)
  var vat         = parseFloat(tr.down('.input_vat').value)
  
  var td_total            = tr.down('.total')
  var td_total_with_taxes = tr.down('.total_with_taxes')
  
  if (isNaN(unit_price)) { unit_price = 0 }
  if (isNaN(quantity)) { quantity = 0 }
  if (isNaN(vat)) { vat = 0 }
  
  // total
  var total = ( unit_price * quantity )
  td_total.update( roundNumber(total, 2) )
  
  // total with taxes
  var total_with_taxes = ( total + ( total * ( vat / 100 ) ) )
  td_total_with_taxes.update( roundNumber(total_with_taxes, 2) )
  
  update_aggregates();
}

function update_aggregates() {
  var items_container     = $('invoice_items_body')
  var aggregate_container = $('invoice_items_foot')
  
  var span_aggregate_without_taxes  = aggregate_container.down('.aggregate_without_taxes').down('span')
  var span_aggregate_all_taxes      = aggregate_container.down('.aggregate_all_taxes').down('span')
  var span_aggregate_net_to_paid    = aggregate_container.down('.aggregate_net_to_paid').down('span')
  
  // aggregates
  var items = items_container.select('tr.invoice_item')
  var totals_without_taxes = new Array()
  var totals_with_taxes = new Array()
  
  items.each(function(item){
    if (item.getStyle('display') != 'none') {
      totals_without_taxes.push(item.down('.total'))
      totals_with_taxes.push(item.down('.total_with_taxes'))
    }
  });
  
  // aggregate without taxes
  var aggregate_without_taxes = parseFloat(0)
  totals_without_taxes.each(function(item){
    aggregate_without_taxes += parseFloat(item.innerHTML.toString().trim())
  });
  span_aggregate_without_taxes.update( roundNumber(aggregate_without_taxes, 2) )
  
  // aggregate with taxes
  var aggregate_with_taxes = parseFloat(0)
  totals_with_taxes.each(function(item){
    aggregate_with_taxes += parseFloat(item.innerHTML.toString().trim())
  });
  span_aggregate_net_to_paid.update( roundNumber(aggregate_with_taxes, 2) )
  
  // aggregate all taxes
  span_aggregate_all_taxes.update( roundNumber(aggregate_with_taxes - aggregate_without_taxes, 2) )
  
  check_values_of_total_and_due_dates();
}
