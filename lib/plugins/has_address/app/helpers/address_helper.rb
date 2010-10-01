module AddressHelper
  def custom_text_field_with_auto_complete_for_city_zip_code(owner_type, address, object_name, options = {})
    custom_text_field_with_auto_complete_for("city", "zip_code", "zip_code", owner_type, address, object_name, options)
  end
  
  def custom_text_field_with_auto_complete_for_city_name(owner_type, address, object_name, options = {})
    custom_text_field_with_auto_complete_for("city", "name", "city_name", owner_type, address, object_name, options)
  end
  
  def custom_text_field_with_auto_complete_for_region_name(owner_type, address, object_name, options = {})
    custom_text_field_with_auto_complete_for("region", "name", "region_name", owner_type, address, object_name, options)
  end
  
  def custom_text_field_with_auto_complete_for_country_name(owner_type, address, object_name, options = {})
    custom_text_field_with_auto_complete_for("country", "name", "country_name", owner_type, address, object_name, options, false)
  end
  
  def city_zip_code_auto_complete_result(items, phrase)
    entries = items.uniq.map { |entry| {:id => entry.id, :value => entry.zip_code, :other_text => " (#{entry.name}, #{(entry.region.name + ', ') if entry.region}#{entry.country.name})"} }
    address_auto_complete_result(entries, phrase)
  end
  
  def city_name_auto_complete_result(items, phrase)
    entries = items.uniq.map { |entry| {:id => entry.id, :value => entry.name, :other_text => " (#{entry.zip_code}, #{(entry.region.name + ', ')if entry.region}#{entry.country.name})"} }
    address_auto_complete_result(entries, phrase)
  end
  
  def region_name_auto_complete_result(items, phrase)
    address_auto_complete_result(items.uniq.map { |entry| {:id => entry.id, :value => entry.name, :other_text => " (#{entry.country.name})"} }, phrase)
  end
  
  def country_name_auto_complete_result(items, phrase)
    address_auto_complete_result(items.uniq.map { |entry| {:id => entry.id, :value => entry.name} }, phrase, false)
  end
  
  private
    def custom_text_field_with_auto_complete_for(object, method, address_method, owner_type, address, form_object_name, tag_options, with_after_update = true)
      random_identifier              = generate_random_id
      form_object_name               = form_object_name + "[]" if tag_options.include?(:index) && tag_options[:index].nil?
      current_value                  = address.send(address_method).to_s
      address_method                 = address_method.to_s
      text_field_identifier          = "#{object}_#{method}_#{random_identifier}"
      hidden_field_for_id_identifier = "#{object}_id_#{random_identifier}"
      
      tag_options        = { :class        => address_method,
                             :value        => current_value,
                             :id           => "#{text_field_identifier}_autocomplete",
                             :name         => "autocomplete_phrase",
                             :onchange     => "this.up('.auto_complete_container').down('.#{address_method}').value = this.value" }.merge(tag_options)
                             
      completion_options = { :skip_style           => true,
                             :frequency            => 0.7,
                             :url                  => send("auto_complete_for_#{object}_#{method}_path"),
                             :indicator            => "auto_complete_indicator_#{random_identifier}",
                             :update_element       => "function(li){
                                                         this.element = $('#{text_field_identifier}_autocomplete')
                                                         target_value = li.down('.auto_complete_returned_value')
                                                         if (target_value) { this.element.value = target_value.innerHTML };
                                                         if (this.afterUpdateElement) { this.afterUpdateElement(this.element, li) }
                                                       }" }
      
      if with_after_update
        completion_options = { :after_update_element => "function(input,li){
                                                           target_id = li.down('.auto_complete_selected_id')
                                                           if (target_id) { 
                                                             $('#{hidden_field_for_id_identifier}').value = target_id.innerHTML 
                                                             $('#{hidden_field_for_id_identifier}').onchange()
                                                           }
                                                         }", 
                               :update_id            => "#{hidden_field_for_id_identifier}"}.merge(completion_options)
      end
      
      html =  "<div class=\"auto_complete_container\">"
      html << hidden_field_tag("#{form_object_name}[#{address_method}]", current_value, :class => address_method)
      html << hidden_field_tag("#{hidden_field_for_id_identifier}", '', :onchange => with_after_update ? remote_function(:url => {:controller => "#{object.pluralize}", :action => "auto_complete_from_#{object}"}, :with => "'id='+this.value+'&random_identifier=#{random_identifier}'") : nil)
      html << text_field_with_auto_complete(object, "#{method}_#{random_identifier}_autocomplete", tag_options, completion_options)
      html << content_tag(:div, nil, :id => "auto_complete_indicator_#{random_identifier}", :class => "auto_complete_indicator", :style => "display:none")
      html << "</div>"
      html
    end

    def address_auto_complete_result(entries, phrase, with_after_update = true)
      if entries.any?
        items = entries.uniq.map do |entry|
          text        = "#{entry[:value]} #{entry[:other_text]}"
          li_content  = content_tag( 'div', phrase ? highlight(entry[:value], phrase, :ignore_special_chars => true) + h(entry[:other_text]) : h(text) ) +
                        content_tag( 'div', h(text),  :style => 'display:none', :class => "auto_complete_selected_value" ) +
                        content_tag( 'div', h(entry[:value]),  :style => 'display:none', :class => "auto_complete_returned_value" )
          li_content += content_tag( 'div', entry[:id], :style => 'display:none', :class => "auto_complete_selected_id" ) if with_after_update

          content_tag 'li', li_content
        end
      else
        items = content_tag 'li', "Aucun résultat"
      end
      content_tag 'ul', items
    end
end
