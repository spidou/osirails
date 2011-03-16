var Quote = Class.create(OsirailsBase, {
  initialize: function(root_element) {
    this.root = Object.isElement(root_element) ? root_element : $(root_element)
    this.quote_items = []
    
    this.quote_items_selector = '#quote_items > tbody'
    
    this._total           = this.root.down('#quote_items tfoot table span.total')
    this._prizegiving     = this.root.down('#quote_items tfoot table span.prizegiving input')
    this._net             = this.root.down('#quote_items tfoot table span.net')
    this._carriage_costs  = this.root.down('#quote_items tfoot table span.carriage_costs input')
    this._summon_of_taxes = this.root.down('#quote_items tfoot table span.summon_of_taxes')
    this._net_to_paid     = this.root.down('#quote_items tfoot table span.net_to_paid')
    
    this._add_item_button = this.root.down('#quote_items tfoot tr.new_quote_item .add_item')
    
    this.bind_update_net              = this.update_net.bindAsEventListener(this)
    this.bind_update_summon_of_taxes  = this.update_summon_of_taxes.bindAsEventListener(this)
    this.bind_add_item                = this.add_item.bindAsEventListener(this)
    
    Event.observe(window, 'load', this.initialize_quote_items.bindAsEventListener(this))
    Event.observe(window, 'load', this.initialize_event_listeners.bindAsEventListener(this))
  },
  
  initialize_quote_items: function() {
    this.update_quote_items()
  },
  
  initialize_event_listeners: function() {
    this._prizegiving.observe('keyup', this.bind_update_net)
    this._carriage_costs.observe('keyup', this.bind_update_summon_of_taxes)
    if (this._add_item_button) this._add_item_button.observe('click', this.bind_add_item)
  },
  
  update_quote_items: function() {
    var position = 0
    this.root.select(this.quote_items_selector + ' tr.quote_item').each(function(tr){
      var existing_item = this.quote_items.detect(function(item){ return item.root == tr })
      if (existing_item == undefined)
        existing_item = this.initialize_quote_item(tr)
      
      if (existing_item.should_destroy()) {
        existing_item.update_position(0)
      } else {
        position++
        existing_item.update_position(position)
      }
    }, this)
    
    this.quote_items = this.quote_items.reject(function(item){ return item.should_destroy() }).sortBy(function(item){ return item.position() })
    
    this.update_all_up_down_links()
    this.update_total()
  },
  
  initialize_quote_item: function(tr, position) {
    position = position || 0
    if (tr.hasClassName('free_item'))
      quote_item = new FreeQuoteItem(tr, { quote: this, position: position })
    else if (tr.hasClassName('product_item'))
      quote_item = new ProductQuoteItem(tr, { quote: this, position: position })
    else if (tr.hasClassName('service_item'))
      quote_item = new ServiceQuoteItem(tr, { quote: this, position: position })
    else {
      alert("Ouch! This quote has an unrecognized kind of line. Please contact your adminstrator.")
      error("This quote has an unexpected kind of line. We expect one of the following classes 'free_item', 'product_item' and 'service_item', but has: "+ tr.classNames())
      error(tr)
      return
    }
    
    this.quote_items.push(quote_item)
    return this.quote_items.last()
  },
  
  add_item: function() {
    var autocomplete_field = $(this._add_item_button.readAttribute('data-field-id'))
    var remote_path = this._add_item_button.readAttribute('data-remote-path')
    var authenticity_token = this._add_item_button.readAttribute('data-token')
    
    var reference_type = autocomplete_field.readAttribute('data-autocomplete-reference-type') // like 'product_reference' or 'service_delivery'
    var reference_id = autocomplete_field.readAttribute('data-autocomplete-reference-id')
    
    if ( (value = autocomplete_field.readAttribute('data-autocomplete-value')) == undefined || value == "") {
      alert("Vous devez d'abord choisir un produit ou une prestation dans le champ ci-contre")
      return;
    }
    
    var reference_already_chosen = false
    var line_reference = null
    
    this.quote_items.reject(function(item){ return item.is_free_item() }).each(function(item) {
      item_type = item.root.down('.reference_object_type').value //TODO use a method of QuoteItem to access to this value
      item_id = item.root.down('.reference_object_id').value     //TODO idem
      if (reference_type == item_type && reference_id == item_id) {
        reference_already_chosen = true
        line_reference = item
        throw $break;
      }
    })
    
    if ( parseInt(reference_id) > 0 && ( !reference_already_chosen || ( reference_already_chosen && confirm("Cette référence existe déjà pour ce devis. Êtes-vous sûr de vouloir ajouter une nouvelle ligne avec cette référence ?") ) ) ) {
      new Ajax.Request(remote_path, {
        method: 'post',
        parameters: { 'reference_object_type':reference_type,
                      'reference_object_id':reference_id,
                      'authenticity_token':authenticity_token },
        onSuccess: function(transport) {
          quote.root.down(quote.quote_items_selector).insert({ bottom: transport.responseText })
          
          quote.update_quote_items()
          initialize_autoresize_text_areas()
          
          quote.quote_items.last().highlight()
        }
      });
    }
  },
  
  update_all_up_down_links: function() {
    this.quote_items.each(function(item){ item.update_up_down_links() })
  },
  
  total: function() {
    return parseFloat(this._total.readAttribute('real-value')) || 0.0
  },
  
  update_total: function() {
    var total = this.quote_items.reject(function(item){ return item.is_free_item() }).collect(function(item){ return item.total() }).sum()
    this.update_and_highlight_element(this._total, total)
    
    this.update_net()
  },
  
  prizegiving: function() {
    return parseFloat(this._prizegiving.value) || 0.0
  },
  
  net: function() {
    return parseFloat(this._net.readAttribute('real-value')) || 0.0
  },
  
  update_net: function() {
    var net = this.total() * ( 1 - (this.prizegiving()/100) )
    this.update_and_highlight_element(this._net, net)
    
    this.update_summon_of_taxes()
  },
  
  carriage_costs: function() {
    return parseFloat(this._carriage_costs.value) || 0.0
  },
  
  summon_of_taxes: function() {
    return parseFloat(this._summon_of_taxes.readAttribute('real-value')) || 0.0
  },
  
  update_summon_of_taxes: function() {
    var summon_of_taxes = this.quote_items.reject(function(item){ return item.is_free_item() }).collect(function(item){ return item.taxes() }).sum()
    this.update_and_highlight_element(this._summon_of_taxes, summon_of_taxes)
    
    this.update_net_to_paid()
  },
  
  update_net_to_paid: function() {
    var net_to_paid = this.net() + this.summon_of_taxes() + this.carriage_costs()
    this.update_and_highlight_element(this._net_to_paid, net_to_paid)
  }
})

var QuoteItem = Class.create(OsirailsBase, {
  initialize: function(root_element, options) {
    this.root = Object.isElement(root_element) ? root_element : $(root_element)
    this.quote = options.quote
    
    this._position = this.root.down('input.position')
    this._remove_button = this.root.down('a[data-icon=delete_line]')
    
    if (!this.is_free_item()) {
      this._unit_price                  = this.root.down('span.unit_price')
      this._prizegiving                 = this.root.down('span.prizegiving input')
      this._unit_price_with_prizegiving = this.root.down('span.unit_price_with_prizegiving')
      this._quantity                    = this.root.down('span.quantity input')
      this._total                       = this.root.down('span.total')
      this._vat                         = this.root.down('span.vat select')
      this._total_with_taxes            = this.root.down('span.total_with_taxes')
      
      this.bind_update_unit_price_with_prizegiving  = this.update_unit_price_with_prizegiving.bindAsEventListener(this)
      this.bind_update_total                        = this.update_total.bindAsEventListener(this)
      this.bind_update_total_with_taxes             = this.update_total_with_taxes.bindAsEventListener(this)
    }
    
    if (options.position != undefined)
      this.update_position(options.position)
    
    this.bind_remove = this.remove.bindAsEventListener(this)
    
    this.initialize_event_listeners()
  },
  
  initialize_event_listeners: function() {
    if (!this.is_free_item()) {
      this._prizegiving.observe('keyup', this.bind_update_unit_price_with_prizegiving)
      this._quantity.observe('keyup', this.bind_update_total)
      this._vat.observe('change', this.bind_update_total_with_taxes)
    }
    
    if (this._remove_button)
      this._remove_button.observe('click', this.bind_remove)
    
    // call TableLine observers
    this.init_table_line_observers()
  },
  
  is_free_item: function() {
    return false;
  },
  
  is_product_item: function() {
    return false;
  },
  
  is_service_item: function() {
    return false;
  },
  
  identifier: function() {
    return parseInt(this.root.down('.quote_item_id').value)
  },
  
  position: function() {
    return parseInt(this._position.value) || 0
  },
  
  update_position: function(position) {
    this._position.value = position
  },
  
  should_destroy: function() {
    return this.root.down('.should_destroy').value > 0
  },
  
  mark_to_destroy: function() {
    this.root.down('.should_destroy').value = 1
  },
  
  unit_price: function() {
    return parseFloat(this._unit_price.readAttribute('real-value')) || 0.0
  },
  
  prizegiving: function() {
    return parseFloat(this._prizegiving.value) || 0.0
  },
  
  unit_price_with_prizegiving: function() {
    return parseFloat(this._unit_price_with_prizegiving.readAttribute('real-value')) || 0.0
  },
  
  update_unit_price_with_prizegiving: function() {
    var unit_price_with_prizegiving = this.unit_price() * ( 1 - ( this.prizegiving()/100 ) )
    this.update_and_highlight_element(this._unit_price_with_prizegiving, unit_price_with_prizegiving)
    
    this.update_total()
  },
  
  quantity: function() {
    return parseFloat(this._quantity.value) || 0.0
  },
  
  total: function() {
    return parseFloat(this._total.readAttribute('real-value')) || 0.0
  },
  
  update_total: function() {
    var total = this.unit_price_with_prizegiving() * this.quantity()
    this.update_and_highlight_element(this._total, total)
    
    this.update_total_with_taxes()
  },
  
  vat: function() {
    return parseFloat(this._vat.value) || 0.0
  },
  
  taxes: function() {
    return ( this.total() * this.vat() / 100.0 ) || 0.0
  },
  
  total_with_taxes: function() {
    return parseFloat(this._total_with_taxes.readAttribute('real-value')) || 0.0
  },
  
  update_total_with_taxes: function() {
    var total_with_taxes = this.total() * ( 1 + ( this.vat()/100 ) )
    this.update_and_highlight_element(this._total_with_taxes, total_with_taxes)
    
    this.quote.update_total()
  },
  
  remove: function() {
    if (confirm(this._remove_button.readAttribute('data-confirm'))) {
      if (this.identifier() == 0) {
        this.root.remove()
      } else {
        this.root.hide()
        this.mark_to_destroy()
      }
      
      this.quote.update_quote_items()
    }
  },
  
  //// the following methods are necessary for TableLine
  move_up_button: function() {
    return this.root.down('a[data-icon=move_up]')
  },
  
  move_down_button: function() {
    return this.root.down('a[data-icon=move_down]')
  },
  
  self_and_siblings: function() {
    return this.quote.quote_items
  },
  
  udpate_and_sort_items: function() {
    this.quote.update_quote_items()
  }
  //// end
})

Object.extend(QuoteItem.prototype, TableLine);

var FreeQuoteItem = Class.create(QuoteItem, {
  initialize: function($super, root_element, options) {
    $super(root_element, options)
  },
  
  is_free_item: function() {
    return true;
  }
})

var ProductQuoteItem = Class.create(QuoteItem, {
  initialize: function($super, root_element, options) {
    $super(root_element, options)
    
    this._unit_price_input = this.root.down('span.unit_price input')
    
    this.bind_update_unit_price = this.update_unit_price.bindAsEventListener(this)
    
    this.initialize_product_event_listeners()
  },
  
  is_product_item: function() {
    return true;
  },
  
  initialize_product_event_listeners: function() {
    if (this._unit_price_input) {
      this._unit_price_input.observe('keyup', this.bind_update_unit_price)
    }
  },
  
  update_unit_price: function() {
    this.update_real_value_element(this._unit_price, this._unit_price_input.value)
    
    this.update_unit_price_with_prizegiving()
  },
})

var ServiceQuoteItem = Class.create(QuoteItem, {
  initialize: function($super, root_element, options) {
    $super(root_element, options)
  },
  
  is_service_item: function() {
    return true;
  }
})


function update_account(tax){
  var account = $('quote_account')
  var account_with_taxes = $('quote_account_with_taxes')
  
  account_with_taxes.update(roundNumber(account.value *(1+tax/100), 2))
}
