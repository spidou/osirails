// TODO puts into this class all methods which concern due_dates or other stuffs related to Invoice
var InvoiceBase = Class.create(OsirailsBase, {
  initialize: function(root_element) {
    this.due_dates = []
    
    Event.observe(window, 'load', this.initialize_due_dates.bindAsEventListener(this))
  },
  
  initialize_due_dates: function() {
    //TODO
  }
})


var DepositInvoice = Class.create(InvoiceBase, {
  initialize: function($super) {
    $super()
  }
})


var Invoice = Class.create(InvoiceBase, {
  initialize: function($super, root_element) {
    $super(root_element)
    
    this.root = Object.isElement(root_element) ? root_element : $(root_element)
    this.invoice_items = []
    
    this.invoice_items_selector = '#invoice_items'
    
    this._total           = this.root.down('tfoot .aggregates span.aggregate_total')
    this._summon_of_taxes = this.root.down('tfoot .aggregates span.aggregate_summon_of_taxes')
    this._net_to_paid     = this.root.down('tfoot .aggregates span.aggregate_net_to_paid')
    
    this.quote_total    = parseFloat(this.root.down('tfoot .invoicing_state span.invoicing_state_quote_total').readAttribute('real-value')) || 0.0
    this.already_billed = parseFloat(this.root.down('tfoot .invoicing_state span.invoicing_state_already_billed').readAttribute('real-value')) || 0.0
    
    this._total_billed    = this.root.down('tfoot .invoicing_state span.invoicing_state_total_billed')
    this._balance         = this.root.down('tfoot .invoicing_state span.invoicing_state_balance')
    
    this._add_free_item = this.root.down('input.add_free_item')
    
    Event.observe(window, 'load', this.initialize_invoice_items.bindAsEventListener(this))
    Event.observe(window, 'load', this.initialize_event_listeners.bindAsEventListener(this))
  },
  
  initialize_invoice_items: function() {
    this.update_invoice_items()
  },
  
  initialize_event_listeners: function() {
    Event.observe(this._add_free_item, 'click', this.add_free_item.bindAsEventListener(this))
  },
  
  update_invoice_items: function() {
    var position = 0
    this.root.select(this.invoice_items_selector + ' tr.invoice_item').each(function(tr){
      position++ // position = 1 on first pass
      
      var existing_item = this.invoice_items.detect(function(item){ return item.root == tr })
      if (existing_item == undefined)
        this.initialize_invoice_item(tr, position)
      else
        existing_item.update_position(position)
      
    }, this)
    
    this.invoice_items = this.invoice_items.select(function(item){ // remove invoice_items which are not present anymore in the table
      return this.root.select(this.invoice_items_selector + ' tr.invoice_item').detect(function(i){ return i == this.root }, item)
    }, this) 
    this.invoice_items = this.invoice_items.reject(function(item){ return item.should_destroy() }).sortBy(function(item){ return item.position() })
    
    //this.update_all_up_down_links()
    this.update_total()
  },
  
  initialize_invoice_item: function(tr, position) {
    position = position || 0
    this.invoice_items.push(new InvoiceItem(tr, { invoice: this, position: position }))
    return this.invoice_items.last()
  },
  
  add_free_item: function() {
    tfoot = this.root.down(this.invoice_items_selector + ' > tfoot')
    tbody = this.root.down(this.invoice_items_selector + ' #other_invoice_items_body')
    
    new_line = tfoot.down('.invoice_item').cloneNode(true)
    tbody.insert({'bottom' : new_line})
    
    new_line = tbody.childElements().last();
    new_line.down('.should_destroy').removeAttribute('value');
    new_line.removeAttribute('style');
    
    new Effect.Highlight(new_line, {afterFinish: function(){ new_line.setStyle({backgroundColor: ''}) }})
    
    this.update_invoice_items()
  },
  
  total: function() {
    return parseFloat(this._total.readAttribute('real-value')) || 0.0
  },
  
  update_total: function() {
    var total = this.invoice_items.reject(function(item){ return item.should_destroy() }).collect(function(item){ return item.total() }).sum()
    this.update_and_highlight_element(this._total, total)
    
    this.update_summon_of_taxes()
  },
  
  summon_of_taxes: function() {
    return parseFloat(this._summon_of_taxes.readAttribute('real-value')) || 0.0
  },
  
  update_summon_of_taxes: function() {
    var summon_of_taxes = this.invoice_items.reject(function(item){ return item.should_destroy() }).collect(function(item){ return item.taxes() }).sum()
    this.update_and_highlight_element(this._summon_of_taxes, summon_of_taxes)
    
    this.update_net_to_paid()
  },
  
  net_to_paid: function() {
    return parseFloat(this._net_to_paid.readAttribute('real-value')) || 0.0
  },
  
  update_net_to_paid: function() {
    var net_to_paid = this.invoice_items.reject(function(item){ return item.should_destroy() }).collect(function(item){ return item.total_with_taxes() }).sum()
    this.update_and_highlight_element(this._net_to_paid, net_to_paid)
    
    this.update_invoicing_state()
    check_values_of_total_and_due_dates()
  },
  
  total_billed: function() {
    return parseFloat(this._total_billed.readAttribute('real-value')) || 0.0
  },
  
  update_total_billed: function() {
    var total_billed = this.already_billed + this.net_to_paid()
    this.update_and_highlight_element(this._total_billed, total_billed)
  },
  
  balance: function() {
    return parseFloat(this._balance.readAttribute('real-value')) || 0.0
  },
  
  update_balance: function() {
    var balance = this.quote_total - this.total_billed()
    this.update_and_highlight_element(this._balance, balance)
  },
  
  update_invoicing_state: function() {
    this.update_total_billed()
    this.update_balance()
  }
  
});

var InvoiceItem = Class.create(OsirailsBase, {
  initialize: function(root_element, options) {
    this.root = Object.isElement(root_element) ? root_element : $(root_element)
    this.invoice = options.invoice
    
    this._position = this.root.down('input.position')
    
    if (this.is_free_item()) {
      this._unit_price  = this.root.down('input.unit_price')
      this._quantity    = this.root.down('input.quantity')
      this._vat         = this.root.down('select.vat')
      this._remove_free_item = this.root.down('.remove_free_item')
    } else {
      this._unit_price  = this.root.down('span.unit_price')
      this._vat         = this.root.down('span.vat')
    }
    
    if (this.is_product_item())
      this._quantity    = this.root.down('span.quantity')
    else if (this.is_service_item())
      this._quantity    = this.root.down('select.quantity') || this.root.down('input.quantity')
    
    this._total             = this.root.down('span.total')
    this._total_with_taxes  = this.root.down('span.total_with_taxes')
    
    if (options.position != undefined)
      this.update_position(options.position)
    
    this.bind_update_total = this.update_total.bindAsEventListener(this)
    this.bind_update_total_with_taxes = this.update_total_with_taxes.bindAsEventListener(this)
    this.bind_remove = this.remove.bindAsEventListener(this)
    this.bind_update_should_destroy_state = this.update_should_destroy_state.bindAsEventListener(this)
    
    this.initialize_event_listeners()
  },
  
  initialize_event_listeners: function() {
    if (this.is_free_item()) {
//      // remove existing observer to avoid multiple observers for the same action on the same object
//      this._unit_price.stopObserving('keyup', this.bind_update_total)
//      this._vat.stopObserving('change', this.bind_update_total_with_taxes)
//      this._remove_free_item.stopObserving('click', this.bind_remove)
      
      // add observers
      this._unit_price.observe('keyup', this.bind_update_total)
      this._vat.observe('change', this.bind_update_total_with_taxes)
      this._remove_free_item.observe('click', this.bind_remove)
    }
    
    if (this._quantity.nodeName == "SELECT") {
      this._quantity.observe('change', this.bind_update_total)
      this._quantity.observe('change', this.bind_update_should_destroy_state)
    }
    else if (this._quantity.nodeName == "INPUT") {
      this._quantity.observe('keyup', this.bind_update_total)
      this._quantity.observe('keyup', this.bind_update_should_destroy_state)
    }
  },
  
  is_free_item: function() {
    return this.root.hasClassName('free_item')
  },
  
  is_product_item: function() {
    return this.root.hasClassName('product_item')
  },
  
  is_service_item: function() {
    return this.root.hasClassName('service_item')
  },
  
  identifier: function() {
    return parseInt(this.root.down('.invoice_item_id').value)
  },
  
  position: function() {
    return parseInt(this._position.value) || 0
  },
  
  update_position: function(position) {
    this._position.value = position
  },
  
  update_should_destroy_state: function() { // only used for service_item
    if (this.quantity() == 0)
      this.mark_to_destroy()
    else
      this.unmark_to_destroy()
    
    this.invoice.update_invoice_items()
  },
  
  should_destroy: function() {
    if (this.is_free_item())
      return this.root.down('.should_destroy').value > 0
    else
      return this.root.hasClassName('should_destroy') // don't know if it really used
  },
  
  mark_to_destroy: function() {
    if (this.is_free_item())
      this.root.down('.should_destroy').value = 1
    else
      this.root.addClassName('should_destroy')
  },
  
  unmark_to_destroy: function() { // only used for service_item
    if (this.is_free_item())
      this.root.down('.should_destroy').value = 0 // never used...
    else
      this.root.removeClassName('should_destroy')
  },
  
  unit_price: function() {
    if (this.is_free_item())
      return parseFloat(this._unit_price.value) || 0.0
    else
      return parseFloat(this._unit_price.readAttribute('real-value')) || 0.0
  },
  
  quantity: function() {
    if (this.is_product_item())
      return parseFloat(this._quantity.readAttribute('real-value')) || 0.0
    else {
      return parseFloat(this._quantity.value) || 0.0
    }
  },
  
  vat: function() {
    if (this.is_free_item())
      return parseFloat(this._vat.value) || 0.0
    else
      return parseFloat(this._vat.readAttribute('real-value')) || 0.0
  },
  
  taxes: function() {
    return ( this.total() * this.vat() / 100.0 ) || 0.0
  },
  
  total: function() {
    return parseFloat(this._total.readAttribute('real-value')) || 0.0
  },
  
  update_total: function() {
    var total = this.unit_price() * this.quantity()
    
    if (total != this.total()) {
      this.update_and_highlight_element(this._total, total)
      this.update_total_with_taxes()
      return this.total()
    }
  },
  
  total_with_taxes: function() {
    return parseFloat(this._total_with_taxes.readAttribute('real-value')) || 0.0
  },
  
  update_total_with_taxes: function() {
    var total_with_taxes = this.total() * ( 1 + ( this.vat()/100 ) )
    
    if (total_with_taxes != this.total_with_taxes()) {
      this.update_and_highlight_element(this._total_with_taxes, total_with_taxes)
      this.invoice.update_total()
      return this.total_with_taxes()
    }
  },
  
  remove: function() {
    if (this.is_free_item()) {
      if (confirm(this._remove_free_item.readAttribute('data-confirm'))) {
        if (this.identifier() == 0) {
          this.mark_to_destroy()
          this.root.hide()
        } else {
          this.root.remove()
        }
        
        this.invoice.update_invoice_items()
      }
    } else {
      return 'Hoho! A product item cannot be removed by this way. Only free item can be removed manually'
    }
  }
  
});



function update_deposit_amount(element) {
  total = parseFloat($('signed_quote_total_with_taxes').innerHTML)
  $('invoice_deposit_amount').value = Math.round(total * parseFloat(element.value)) / 100
  parent = $('invoice_deposit_amount').up('p')
  new Effect.Highlight(parent, {afterFinish: function(){ parent.setStyle({backgroundColor: ''}); }})
  
  update_deposit_amount_without_taxes($('invoice_deposit_amount'))
}

function update_deposit_amount_without_taxes(element) {
  deposit_vat = parseFloat($('invoice_deposit_vat').value)
  deposit_amount = parseFloat(element.value)
  deposit_amount_without_taxes = deposit_amount / ( 1 + ( deposit_vat / 100 ) )
  $('deposit_amount_without_taxes').update(Math.round(deposit_amount_without_taxes*100)/100)
  new Effect.Highlight($('deposit_amount_without_taxes'), {afterFinish: function(){ $('deposit_amount_without_taxes').setStyle({backgroundColor: ''}) }})
  
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
    invoice_nav.tabs.detect(function(tab){ return tab.name == "due_dates_payments" }).warn()
  } else {
    $('due_date_amounts_notification').fade()
    invoice_nav.tabs.detect(function(tab){ return tab.name == "due_dates_payments" }).unwarn()
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
      form_buttons.each(function(button){
        button.disable()
      });
    },
    onLoaded: function() {
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
