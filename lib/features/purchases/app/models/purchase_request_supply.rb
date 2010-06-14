class PurchaseRequestSupply < ActiveRecord::Base
  
  belongs_to :purchase_request
  belongs_to :purchase_order_supply
  belongs_to :supply
  
  validates_presence_of :supply_id, :expected_quantity, :expected_delivery_date
  validates_numericality_of :expected_quantity, :greater_than => 0
  
  STATUS_UNTREATED = "untreated"
  
  named_scope :actives, :conditions => [ 'status = ?', STATUS_UNTREATED ]
  
  def check_status
    status = ''   
    status = PurchaseRequest::STATUS_UNTRAITED unless self.purchase_order_supply_id
    status = PurchaseRequest::STATUS_DURING_TRAITMENT if self.purchase_order_supply_id and  self.purchase_order_supply.purchase_order.status == PurchaseOrder::STATUS_DRAFT and self.purchase_order_supply.purchase_order.cancelled_by == nil
    status = PurchaseRequest::STATUS_DURING_TRAITMENT if self.purchase_order_supply_id and  self.purchase_order_supply.purchase_order.status != PurchaseOrder::STATUS_DRAFT and self.purchase_order_supply.purchase_order.cancelled_by == nil   
    status
  end
  
  def self.get_all_suppliers_for_all_purchase_request_supplies
    purchase_request_supplies = PurchaseRequestSupply.all
    suppliers = []
    for purchase_request_supply in purchase_request_supplies
      suppliers += purchase_request_supply.supply.suppliers
    end
    suppliers.uniq
  end
  
  def self.get_all_purchase_request_supplies_by_supplier(supplier = nil)
    if supplier
      purchase_request_supplies = PurchaseRequestSupply.all#(:conditions => ["cancelled_by IS NULL and purchase_order_supply_id IS NULL"]) à revoir quand la nouvelle table de jointure entre les purchase order_supplies et les purchase_request_supplies sera créée
      kept_purchase_request_supplies = []
      for purchase_request_supply in purchase_request_supplies
        for purchase_request_supply_supplier in purchase_request_supply.supply.suppliers
          if purchase_request_supply_supplier == supplier
            kept_purchase_request_supplies << purchase_request_supply
          end
        end
      end
      return kept_purchase_request_supplies
    else
      return []
    end
  end
  
  
  def self.merge_kept_purchase_request_supplies_by_supplier(supplier)
    
    kept_purchase_request_supplies = get_all_purchase_request_supplies_by_supplier(supplier)
    merged_kept_purchase_request_supplies = {}
    for kept_purchase_request_supply_x in kept_purchase_request_supplies
      supplier_supply = SupplierSupply.find_by_supply_id_and_supplier_id(kept_purchase_request_supply_x.supply_id,supplier.id)
      merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id] = { 
                                                                                        :total_expected_quantity => 0,
                                                                                        :designation => "",
                                                                                        :measure => 0,
                                                                                        :reference => "",
                                                                                        :type => "",
                                                                                        :stock_quantity => 0,
                                                                                        :unit_mass => 0,
                                                                                        :threshold => 0,
                                                                                        :fob_unit_price => supplier_supply.fob_unit_price,
                                                                                        :lead_time => supplier_supply.lead_time,
                                                                                        :taxes => supplier_supply.taxes,
                                                                                        :supplier_reference => supplier_supply.supplier_reference
      }
      for kept_purchase_request_supply_y in kept_purchase_request_supplies
        if (kept_purchase_request_supply_x.supply_id == kept_purchase_request_supply_y.supply_id)
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:total_expected_quantity] = merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:total_expected_quantity] + kept_purchase_request_supply_y.expected_quantity
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:designation] = kept_purchase_request_supply_y.supply.designation
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:measure] = kept_purchase_request_supply_y.supply.measure
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:type] = kept_purchase_request_supply_y.supply.type
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:stock_quantity] = kept_purchase_request_supply_y.supply.stock_quantity
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:unit_mass] = kept_purchase_request_supply_y.supply.unit_mass
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:threshold] = kept_purchase_request_supply_y.supply.threshold
          merged_kept_purchase_request_supplies[kept_purchase_request_supply_x.supply_id][:reference] = kept_purchase_request_supply_y.supply.reference
        end
      end
    end
    merged_kept_purchase_request_supplies
  end

end
