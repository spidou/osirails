module Osirails
  module ContextualMenu
    class Section
      @@section_titles.update({ :commodities_stats                => "Statistiques",
                                :restockable_supplies_statistics  => "Statistiques" })
    end
  end
end

require_dependency 'supplier'

class Supplier
  has_many :supplier_supplies
  has_many :supplies, :through => :supplier_supplies
end
