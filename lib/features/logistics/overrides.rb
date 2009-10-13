require_dependency 'supplier'

class Supplier
  has_many :supplier_supplies
  has_many :supplies, :through => :supplier_supplies
  has_many :stock_flows
end

ContextualMenuManager::ContextualSection::SECTION_TITLES.merge!({ :restockable_supplies_statistics => "Statistiques" })
