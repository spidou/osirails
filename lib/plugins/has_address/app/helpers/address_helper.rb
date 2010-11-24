module AddressHelper
  def custom_text_field_with_auto_complete_for_city_zip_code(address, identifier, form, options = {})
    custom_text_field_with_auto_complete_for(:city, :zip_code, :zip_code, address, identifier, form, options)
  end
  
  def custom_text_field_with_auto_complete_for_city_name(address, identifier, form, options = {})
    custom_text_field_with_auto_complete_for(:city, :name, :city_name, address, identifier, form, options)
  end
  
  def custom_text_field_with_auto_complete_for_region_name(address, identifier, form, options = {})
    custom_text_field_with_auto_complete_for(:region, :name, :region_name, address, identifier, form, options)
  end
  
  def custom_text_field_with_auto_complete_for_country_name(address, identifier, form, options = {})
    custom_text_field_with_auto_complete_for(:country, :name, :country_name, address, identifier, form, options)
  end
  
  def city_zip_code_auto_complete_result(items, phrase)
    entries = items.uniq.map{ |city| { :value           => city.zip_code,
                                       :additional_text => "(#{city.name}, #{(city.region.name + ', ') if city.region}#{city.country.name})",
                                       :zip_code        => city.zip_code,
                                       :city_name       => city.name,
                                       :region_name     => city.region ? city.region.name : '',
                                       :country_name    => city.country.name } }
    address_auto_complete_result(entries, phrase)
  end
  
  def city_name_auto_complete_result(items, phrase)
    entries = items.uniq.map{ |city| { :value           => city.name,
                                       :additional_text => "(#{city.zip_code}, #{(city.region.name + ', ') if city.region}#{city.country.name})",
                                       :zip_code        => city.zip_code,
                                       :city_name       => city.name,
                                       :region_name     => city.region ? city.region.name : '',
                                       :country_name    => city.country.name } }
    address_auto_complete_result(entries, phrase)
  end
  
  def region_name_auto_complete_result(items, phrase)
    entries = items.uniq.map{ |region| { :value           => region.name,
                                         :additional_text => "(#{region.country.name})",
                                         :region_name     => region.name,
                                         :country_name    => region.country.name } }
    address_auto_complete_result(entries, phrase)
  end
  
  def country_name_auto_complete_result(items, phrase)
    entries = items.uniq.map{ |country| { :value        => country.name,
                                          :country_name => country.name } }
    address_auto_complete_result(entries, phrase)
  end
  
  private
    def custom_text_field_with_auto_complete_for(object, method, address_method, address, identifier, form, options)
      html = ""
      html << form.hidden_field(address_method, { :class => address_method }.merge(options))
      html << custom_text_field_with_auto_complete(object, method, { :name => "autocomplete_phrase",
                                                                     :class => address_method,
                                                                     :value => address.send(address_method),
                                                                     :style => "",
                                                                     :restoreValue => "",
                                                                     :onkeyup => "this.up('.address').down('input[type=hidden].#{address_method}').value = this.value" },
                                                                   { :identifier           => identifier,
                                                                     :after_update_element => "function(input,li){}",
                                                                     :update_element       => "function(li){
  this.element = $('#{object}_#{method}_#{identifier}');
  var address = this.element.up('.address');

  var zip_code = li.down('.address_zip_code');
  var city_name = li.down('.address_city_name');
  var region_name = li.down('.address_region_name');
  var country_name = li.down('.address_country_name');

  if (zip_code) { address.select('input.zip_code').each(function(item){ item.value = zip_code.innerHTML }) }
  if (city_name) { address.select('input.city_name').each(function(item){ item.value = city_name.innerHTML }) }
  if (region_name) { address.select('input.region_name').each(function(item){ item.value = region_name.innerHTML }) }
  if (country_name) { address.select('input.country_name').each(function(item){ item.value = country_name.innerHTML }) }

  if (this.afterUpdateElement) { this.afterUpdateElement(this.element, li) }
}" })
    end
    
    def address_auto_complete_result(entries, phrase)
      if entries.any?
        items = entries.uniq.map do |entry|
          text        = "#{entry[:value]} #{entry[:additional_text]}"
          li_content  = content_tag( 'div', phrase ? highlight(entry[:value], phrase, :ignore_special_chars => true) + h(entry[:additional_text]) : h(text) )
          li_content += content_tag( 'div', h(entry[:zip_code]),     :style => 'display:none', :class => "address_zip_code" )     if entry[:zip_code]
          li_content += content_tag( 'div', h(entry[:city_name]),    :style => 'display:none', :class => "address_city_name" )    if entry[:city_name]
          li_content += content_tag( 'div', h(entry[:region_name]),  :style => 'display:none', :class => "address_region_name" )  if entry[:region_name]
          li_content += content_tag( 'div', h(entry[:country_name]), :style => 'display:none', :class => "address_country_name" ) if entry[:country_name]

          content_tag 'li', li_content
        end
      else
        items = content_tag 'li', "Aucun résultat"
      end
      content_tag 'ul', items
    end
end
