require_dependency "commodities_query"

module ConsumablesQuery
  include CommoditiesQuery
  
  alias_method :query_td_for_reference_in_consumable,                                 :query_td_for_reference_in_commodity
  alias_method :query_td_for_designation_in_consumable,                               :query_td_for_designation_in_commodity
  alias_method :query_td_for_measure_in_consumable,                                   :query_td_for_measure_in_commodity
  alias_method :query_td_content_for_measure_in_consumable,                           :query_td_content_for_measure_in_commodity
  alias_method :query_td_for_unit_mass_price_in_consumable,                           :query_td_for_unit_mass_price_in_commodity
  alias_method :query_td_content_for_unit_mass_in_consumable,                         :query_td_content_for_unit_mass_in_commodity
  alias_method :query_td_for_average_unit_price_in_consumable,                        :query_td_for_average_unit_price_in_commodity
  alias_method :query_td_content_for_average_unit_price_in_consumable,                :query_td_content_for_average_unit_price_in_commodity
  alias_method :query_td_for_average_measure_price_in_consumable,                     :query_td_for_average_measure_price_in_commodity
  alias_method :query_td_content_for_average_measure_price_in_consumable,             :query_td_content_for_average_measure_price_in_commodity
  alias_method :query_td_content_for_stock_quantity_in_consumable,                    :query_td_content_for_stock_quantity_in_commodity
  alias_method :query_td_content_for_stock_quantity_at_last_inventory_in_consumable,  :query_td_content_for_stock_quantity_at_last_inventory_in_commodity
  alias_method :query_td_for_suppliers_in_consumable,                                 :query_td_for_suppliers_in_commodity
  alias_method :query_td_content_for_suppliers_in_consumable,                         :query_td_content_for_suppliers_in_commodity
end
