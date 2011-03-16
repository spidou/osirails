Event.observe(window, 'load', function() {
  initialize_listeners()
});  

function initialize_listeners() {
  // manage updates of time_scale
  $('service_delivery_time_scale').observe('change', function(event){
    select = event.target
    if (select.value == "") {
      $$('.rate_check_box').each(function(cb){
        cb.checked = false
        cb.writeAttribute('readonly', 'readonly')
      })
    } else {
      _pro_rata_billable().removeAttribute('readonly')
      _default_pro_rata_billing().removeAttribute('readonly') // this line may be deleted once the observer on _pro_rata_billable() will be restored (see few lines below)
    }
  })
  
  // manage updates of unit_price
  _unit_price().observe('keyup', function(event){
    update_unit_price_with_taxes()
  })
  
  // manage updates of vat
  _vat().observe('change', function(event){
    update_unit_price_with_taxes()
  })
  
  // manage updates of unit_price_with_taxes
  _unit_price_with_taxes().observe('keyup', function(event){
    update_unit_price()
  })
  
  // This has been disabled because the function enable_readonly_fields (application.js)
  // currently disable all 'onchange' observer on readonly fields, so this observer too.
  // This method may be reactivated once the enable_readonly_fields will restore observers
  // like it should
  //
  //// manage updates of pro_rata_billable
  //_pro_rata_billable().observe('change', function(event){
  //  target = event.target
  //  
  //  _default_pro_rata_billing().writeAttribute('readonly', !target.checked)
  //  
  //  if (!target.checked) {
  //    _default_pro_rata_billing().checked = false
  //  }
  //})
}

function _pro_rata_billable() {
  return $('service_delivery_pro_rata_billable')
}

function _default_pro_rata_billing() {
  return $('service_delivery_default_pro_rata_billing')
}

function _vat() {
  return $('service_delivery_vat')
}

function vat() {
  return parseFloat(_vat().value) || 0.0
}

function _unit_price() {
  return $('service_delivery_unit_price')
}

function unit_price() {
  return parseFloat(_unit_price().value) || 0.0
}

function update_unit_price() {
  var unit_price = parseFloat(unit_price_with_taxes() / ( 1 + (vat()/100) ))
  _unit_price().value = unit_price
}

function _unit_price_with_taxes() {
  return $('unit_price_with_taxes')
}

function unit_price_with_taxes() {
  return parseFloat(_unit_price_with_taxes().value) || 0.0
}

function update_unit_price_with_taxes() {
  var unit_price_with_taxes = parseFloat(unit_price() * ( 1 + (vat()/100) ))
  _unit_price_with_taxes().value = unit_price_with_taxes
}
