module CreateSupplies
  def create_commodities
    @galva = Commodity.new({
                            :name => "Galva",
                            :reference => "glv1234",
                            :measure => 1,
                            :unit_mass => 2,
                            :supply_category => supply_categories(:child_commodity),
                            :threshold => 20
                           })
    flunk "@galva should be valid to perform the next tests" unless @galva.save

    @acier = Commodity.new({
                            :name => "Acier",
                            :reference => "aci1234",
                            :measure => 1,
                            :unit_mass => 2,
                            :supply_category => supply_categories(:child_commodity),
                            :threshold => 20
                           })
    flunk "@acier should be valid to perform the next tests" unless @acier.save
  end

  def create_consumables
    @pvc = Consumable.new({
                           :name => "PVC",
                           :reference => "pvc1234",
                           :measure => 1,
                           :unit_mass => 2,
                           :supply_category => supply_categories(:child_consumable),
                           :threshold => 20
                          })
    flunk "@pvc should be valid to perform the next tests" unless @pvc.save

    @vis = Consumable.new({
                           :name => "Vis",
                           :reference => "vis1234",
                           :measure => 1,
                           :unit_mass => 2,
                           :supply_category => supply_categories(:child_consumable),
                           :threshold => 20
                          })
    flunk "@vis should be valid to perform the next tests" unless @vis.save
  end

  def create_supplier_commodities
    create_commodities
    @galva_ss = SupplierSupply.new({:supply_id => @galva.id,
                               :supplier_id => Supplier.last.id,
                               :reference => "glv",
                               :name => "galva",
                               :fob_unit_price => 10,
                               :tax_coefficient => 0,
                               :lead_time => 15})
    flunk "@galva_ss should save with success" unless @galva_ss.save

    @acier_ss = SupplierSupply.new({:supply_id => @acier.id,
                               :supplier_id => Supplier.last.id,
                               :reference => "acr",
                               :name => "acier",
                               :fob_unit_price => 10,
                               :tax_coefficient => 0,
                               :lead_time => 15})
    flunk "@acier_ss should save with success" unless @acier_ss.save
  end

  def create_supplier_consumables
    create_consumables
    @pvc_ss = SupplierSupply.new({:supply_id => @pvc.id,
                             :supplier_id => Supplier.last.id,
                             :reference => "pvc",
                             :name => "pvc",
                             :fob_unit_price => 10,
                             :tax_coefficient => 0,
                             :lead_time => 15})
    flunk "@pvc_ss should save with success" unless @pvc_ss.save

    @vis_ss = SupplierSupply.new({:supply_id => @vis.id,
                             :supplier_id => Supplier.last.id,
                             :reference => "vis",
                             :name => "vis",
                             :fob_unit_price => 10,
                             :tax_coefficient => 0,
                             :lead_time => 15})
    flunk "@vis_ss should save with success" unless @vis_ss.save
  end

  def create_supplier_supplies
    create_supplier_commodities
    create_supplier_consumables
  end
end

