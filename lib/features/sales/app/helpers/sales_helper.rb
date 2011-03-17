module SalesHelper

  def delivery_service_rate_text(quote_item)
    return unless quote_item.service_item? && quote_item.reference_object && quote_item.reference_object.rate?
    "(#{t("view.service_delivery.rates.#{quote_item.reference_object.time_scale}", :default => quote_item.reference_object.time_scale)})"
  end
  
  def display_delivery_service_rate_text(quote_item) # display_hourly_rated_text(quote_item)
    if text = delivery_service_rate_text(quote_item)
      "<span class=\"rate_text\">#{text}</span>"
    end
  end

end
