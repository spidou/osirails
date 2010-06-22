class PurchaseRequestSupply < ActiveRecord::Base
  
  has_many  :request_order_supplies
  has_many  :purchase_order_supplies, :through => :request_order_supplies
  
  has_one   :confirmed_purchase_order_supply, :through => :request_order_supplies, :include => 'purchase_order', :conditions => [ 'purchase_orders.status IS NOT NULL' ],  :source => :purchase_order_supply
  
  has_many  :draft_purchase_order_supplies, :through => :request_order_supplies, :include => 'purchase_order', :conditions => [ 'purchase_orders.status IS NULL'],  :source => :purchase_order_supply
  
  
  
  belongs_to :purchase_request
  belongs_to :supply
  belongs_to :canceller, :class_name => "User", :foreign_key => 'cancelled_by'
  
  validates_presence_of :supply_id
  validates_persistence_of :expected_delivery_date
  
  validates_numericality_of :expected_quantity, :greater_than => 0
  validates_date :expected_delivery_date, :after => Date.today, :if => :new_record?
  
  STATUS_UNTREATED = "untreated"
  
  named_scope :actives, :conditions => [ 'status = ?', PurchaseRequestSupply::STATUS_UNTREATED ]

  
  def check_request_supply_status
    return PurchaseRequest::STATUS_UNTREATED if self.untreated?  
    return PurchaseRequest::STATUS_DURING_TREATMENT if self.during_treatment? 
    return PurchaseRequest::STATUS_TREATED if self.treated? 
  end
  
  def check_order_supply_status
    
  end
  
  def can_be_cancelled?
    cancelled? ? false : true
  end
  
  def cancelled?
   self.cancelled_at || self.purchase_request.cancelled? 
  end
  
  def cancel
    self.cancelled_at = Time.now
    self.save
  end
  
  def untreated?
    !self.confirmed_purchase_order_supply && self.draft_purchase_order_supplies.empty?
  end
  
  def during_treatment?
    self.draft_purchase_order_supplies.any? && !self.confirmed_purchase_order_supply
  end
  
  def treated?
    self.confirmed_purchase_order_supply
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
