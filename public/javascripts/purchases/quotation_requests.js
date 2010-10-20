function add_existing_supply_to_quotation_request(remote_path, authenticity_token) {
  var supply_id = $('add_this_supply_id').value
  
  var quotation_request_supplies = $('quotation_request_supplies_body').select('.quotation_request_supply')
  var supply_already_chosen = false
  var line_supply = null
  
  quotation_request_supplies.each(function(item) {
    item_id = item.down('.supply_id').value
    if (supply_id == item_id) {
      supply_already_chosen = true
      line_supply = item
      throw $break;
    }
  })
  
  if ( parseInt(supply_id) > 0 && !supply_already_chosen ) {
    new Ajax.Request(remote_path, {
      method: 'post',
      parameters: { 'supply_id':supply_id,
                    'authenticity_token':authenticity_token },
      onSuccess: function(transport) {
	      $('quotation_request_supplies_body').insert({ bottom: transport.responseText })
	      
	      last_element = $('quotation_request_supplies_body').select('tr').last()
	      new Effect.Highlight(last_element, {afterFinish: function(){ last_element.setStyle({backgroundColor: ''}) }})
	      
	      update_up_down_links_for_quotation_request($('quotation_request_supplies_body'));
      }
    });
  }
  else if(supply_already_chosen){
    alert("Cette référence existe déjà pour cette demande de devis.")
    Effect.Pulsate(line_supply, { pulses: 3, duration: 2 })
  }
}

function update_up_down_links_for_quotation_request(element)
{
  elements = element.childElements().reject(function(item) { return parseInt(item.down('.should_destroy').value) == 1 })
  elements = element.childElements().select(function(item) { return item.down('.position') != undefined })
  
  for (var i = 0; i < elements.length; i++) {
    reset_up_down_links(elements[i]);
    update_position(elements[i], i + 1);
  }
  
  if (elements.length > 0) {
    disable_first_link(elements.first());
    disable_last_link(elements.last());
  }
}

function move_up_supply(link)
{
  move_supply_tr(true, link);
}

function move_down_supply(link)
{
  move_supply_tr(false, link);
}

function move_supply_tr(to_up, link)
{
  var element   = $(link).up("TR");
  var neighbour = $(nearly_visible(to_up, element));
  
  if (neighbour == null) return;
  
  (to_up ? neighbour.insert({before: element}) : neighbour.insert({after: element}) );
  new Effect.Highlight(element, {afterFinish: function(){ element.setStyle({backgroundColor: ''}) }})
  
  update_up_down_links_for_quotation_request(element.up("tbody"));
}

function remove_line(element)
{
  if(element.up('tr.quotation_request_supply') != undefined){
    item = element.up('tr.quotation_request_supply')
  }
  else if(element.up('tr.free_quotation_request_supply') != undefined){
    item = element.up('tr.free_quotation_request_supply')
  }
  else{
    item = element.up('tr.comment_line')
  }
  
  if (parseInt(item.down('.quotation_request_supply_id').value) > 0) {
    item.down('.should_destroy').value = 1;
    item.hide();
  } else {
    item.remove();
  }
  
  update_up_down_links_for_quotation_request($('quotation_request_supplies_body'));
}




function update_prs_ids(id){
  $('prs_ids').value = $('purchase_request_supplies').select('.check_boxes').collect(function(item){ if(item.checked){return item.value}}).compact()
}
