# default commodity categories
metal = CommodityCategory.create! :name => "Metal"
alu   = CommodityCategory.create! :name => "Aluminium"
plast = CommodityCategory.create! :name => "Plasturgie"

toles = CommoditySubCategory.create!  :name => "Tôle", :supply_category_id => metal.id, :unit_measure_id => UnitMeasure.find_by_symbol("m²").id,
                                      :supply_categories_supply_size_attributes => [
                                        { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                                          :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                        { :supply_size_id   => SupplySize.find_by_name("Largeur").id,
                                          :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                        { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                                          :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id } ]

tubes = CommoditySubCategory.create!  :name => "Tube", :supply_category_id => metal.id, :unit_measure_id => UnitMeasure.find_by_symbol("m").id,
                                      :supply_categories_supply_size_attributes => [
                                        { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                                          :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                        { :supply_size_id   => SupplySize.find_by_name("Diamètre").id,
                                          :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                        { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                                          :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id } ]

CommoditySubCategory.create!  :name => "Tôle", :supply_category_id => alu.id, :unit_measure_id => UnitMeasure.find_by_symbol("m²").id,
                              :supply_categories_supply_size_attributes => [
                                { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Largeur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id } ]

CommoditySubCategory.create!  :name => "Tube", :supply_category_id => alu.id, :unit_measure_id => UnitMeasure.find_by_symbol("m").id,
                              :supply_categories_supply_size_attributes => [
                                { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Diamètre").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id } ]

CommoditySubCategory.create!  :name => "PVC", :supply_category_id => plast.id, :unit_measure_id => UnitMeasure.find_by_symbol("m²").id,
                              :supply_categories_supply_size_attributes => [
                                { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Largeur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id } ]

CommoditySubCategory.create!  :name => "Altuglass", :supply_category_id => plast.id, :unit_measure_id => UnitMeasure.find_by_symbol("m²").id,
                              :supply_categories_supply_size_attributes => [
                                { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Largeur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id },
                                { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                                  :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id } ]

# default commodities and their supplier_supplies
acier = Commodity.create! :name => "Acier", :measure => "1.60", :unit_mass => "70.65", :supply_sub_category_id => toles.id, :threshold => 5,
                          :supplies_supply_size_attributes => [
                            { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "6" },
                            { :supply_size_id   => SupplySize.find_by_name("Largeur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "940" },
                            { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "1700" } ]

galva = Commodity.create! :name => "Galva", :measure => "4.50", :unit_mass => "105.98", :supply_sub_category_id => toles.id, :threshold => 1,
                          :supplies_supply_size_attributes => [
                            { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "1.5" },
                            { :supply_size_id   => SupplySize.find_by_name("Largeur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "1500" },
                            { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "3000" } ]

rond  = Commodity.create! :name => "Rond", :measure => "6", :unit_mass => "5.32", :supply_sub_category_id => tubes.id, :threshold => 18,
                          :supplies_supply_size_attributes => [
                            { :supply_size_id   => SupplySize.find_by_name("Épaisseur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "2" },
                            { :supply_size_id   => SupplySize.find_by_name("Diamètre").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "20" },
                            { :supply_size_id   => SupplySize.find_by_name("Longueur").id,
                              :unit_measure_id  => UnitMeasure.find_by_symbol("mm").id,
                              :value            => "6000" } ]

SupplierSupply.create! :supply_id       => acier.id,
                       :supplier_id     => Supplier.first.id,
                       :fob_unit_price  => 10,
                       :taxes           => 1,
                       :lead_time       => 15

SupplierSupply.create! :supply_id       => acier.id,
                       :supplier_id     => Supplier.last.id,
                       :fob_unit_price  => 11,
                       :taxes           => 2,
                       :lead_time       => 18

SupplierSupply.create! :supply_id       => galva.id,
                       :supplier_id     => Supplier.first.id,
                       :fob_unit_price  => 12,
                       :taxes           => 50,
                       :lead_time       => 15

SupplierSupply.create! :supply_id       => galva.id,
                       :supplier_id     => Supplier.last.id,
                       :fob_unit_price  => 25,
                       :taxes           => 3,
                       :lead_time       => 18

SupplierSupply.create! :supply_id       => rond.id,
                       :supplier_id     => Supplier.last.id,
                       :fob_unit_price  => 15,
                       :taxes           => 4,
                       :lead_time       => 15

SupplierSupply.create! :supply_id       => rond.id,
                       :supplier_id     => Supplier.first.id,
                       :fob_unit_price  => 9,
                       :taxes           => 0,
                       :lead_time       => 18

# default consumable categories
quinc   = ConsumableCategory.create! :name => "Quincaillerie"
vis     = ConsumableSubCategory.create! :name => "Vis auto-foreuse inox", :supply_category_id => quinc.id
ecrous  = ConsumableSubCategory.create! :name => "Écrou",                 :supply_category_id => quinc.id

# default consumables and their supplier_supplies
tcarre  = Consumable.create! :name => "Tête bombée empreinte carrée",     :supply_sub_category_id => vis.id,    :threshold => 100
tcruci  = Consumable.create! :name => "Tête bombée empreinte cruciforme", :supply_sub_category_id => vis.id,    :threshold => 100
thexa   = Consumable.create! :name => "Tête Hexagonale",                  :supply_sub_category_id => ecrous.id, :threshold => 100

SupplierSupply.create! :supply_id       => tcarre.id,
                       :supplier_id     => Supplier.last.id,
                       :fob_unit_price  => 8,
                       :taxes           => 5,
                       :lead_time       => 20

SupplierSupply.create! :supply_id       => tcarre.id,
                       :supplier_id     => Supplier.first.id,
                       :fob_unit_price  => 10,
                       :taxes           => 1,
                       :lead_time       => 15

SupplierSupply.create! :supply_id       => tcruci.id,
                       :supplier_id     => Supplier.first.id,
                       :fob_unit_price  => 13,
                       :taxes           => 8,
                       :lead_time       => 13

SupplierSupply.create! :supply_id       => tcruci.id,
                       :supplier_id     => Supplier.last.id,
                       :fob_unit_price  => 12,
                       :taxes           => 1,
                       :lead_time       => 12

SupplierSupply.create! :supply_id       => thexa.id,
                       :supplier_id     => Supplier.first.id,
                       :fob_unit_price  => 7,
                       :taxes           => 0,
                       :lead_time       => 15

SupplierSupply.create! :supply_id       => thexa.id,
                       :supplier_id     => Supplier.last.id,
                       :fob_unit_price  => 14,
                       :taxes           => 0,
                       :lead_time       => 11

# default stock_flows
StockInput.create! :supply_id       => acier.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => acier.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => galva.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => galva.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => rond.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => rond.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => tcarre.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => tcarre.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => tcruci.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => tcruci.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => thexa.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

StockInput.create! :supply_id       => thexa.id,
                   :identifier      => 1234567890,
                   :unit_price      => 10,
                   :quantity        => 15

# default vehicles
Vehicle.create! :service_id => Service.first.id,  :job_id => Job.first.id, :employee_id => Employee.first.id, :supplier_id => Supplier.first.id, :name => "Ford Fiesta",    :serial_number => "123 ABC 974", :description => "Véhicule utilitaire",    :purchase_date => Date.today - 1.year,   :purchase_price => "12000"
Vehicle.create! :service_id => Service.last.id,   :job_id => Job.last.id,  :employee_id => Employee.last.id,  :supplier_id => Supplier.last.id,  :name => "Renault Magnum", :serial_number => "456 DEF 974", :description => "Camion longue distance", :purchase_date => Date.today - 6.months, :purchase_price => "130000"

# default machines
Machine.create! :service_id => Service.last.id,   :job_id => Job.last.id,  :employee_id => Employee.last.id,  :supplier_id => Supplier.last.id,  :name => "Fraiseuse",  :serial_number => "987654321", :description => "Fraiseuse",   :purchase_date => Date.today - 6.months,  :purchase_price => "300000"
Machine.create! :service_id => Service.first.id,  :job_id => Job.first.id, :employee_id => Employee.first.id, :supplier_id => Supplier.first.id, :name => "Imprimante", :serial_number => "123456789", :description => "Imprimante",  :purchase_date => Date.today - 1.year,    :purchase_price => "500000"

# default permissions
%W{ BusinessObject Menu DocumentType }.each do |klass|
  klass.constantize.all.each do |object|
    object.permissions.each do |permission|
      permission.permissions_permission_methods.each do |object_permission|
        object_permission.update_attribute(:active, true)
      end
    end
  end
end
