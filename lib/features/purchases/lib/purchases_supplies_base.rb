module PurchasesSuppliesBase
  
  class << self
    def included base #:nodoc:
      base.send :include, InstanceMethods
    end
  end
  
  module InstanceMethods
    def owner_type
      self.class.singularized_table_name.chomp("_supply")
    end
    
    #TODO test this method
    def free_supply_and_not_associated_prs?
      free_supply? and purchase_request_supplies.empty?
    end
    
    #TODO test this method
    def associated_prs_designation
      purchase_request_supplies.last.designation if purchase_request_supplies.any?
    end
    
    #TODO test this method
    def position
      self[:position] ||= 0
    end
    
    def should_destroy?
      should_destroy.to_i == 1
    end
    
    def supplier_supply
      supply_id and send(owner_type) and send(owner_type).supplier_id ? SupplierSupply.find_by_supply_id_and_supplier_id(supply_id, send(owner_type).supplier_id) : nil
    end
    
    def designation
      if existing_supply?
        self[:designation] = supply.designation
      elsif associated_prs_designation
        self[:designation] = associated_prs_designation
      else
        self[:designation]
      end
    end
    
    def supplier_reference
      supplier_supply ? (self[:supplier_reference] ||= supplier_supply.supplier_reference) : self[:supplier_reference]
    end
    
    def supplier_designation
      supplier_supply ? (self[:supplier_designation] ||= supplier_supply.supplier_designation) : self[:supplier_designation]
    end
    
    #TODO test this method
    def can_add_purchase_request_supply_id?(id)
      purchase_request_supplies_deselected_ids && purchase_request_supplies_deselected_ids.split(';').detect{ |deselected_id| deselected_id.to_i == id.to_i } ? false : true
    end
    
    #TODO test this method
    def not_cancelled_purchase_request_supplies
      PurchaseRequestSupply.all(:include => :purchase_request, :conditions => ['purchase_request_supplies.supply_id = ? AND purchase_request_supplies.cancelled_at IS NULL AND purchase_requests.cancelled_at IS NULL', supply_id])
    end
    
    #TODO test this method
    def unconfirmed_purchase_request_supplies
      not_cancelled_purchase_request_supplies.select{ |prs| (new_record? and !prs.confirmed_purchase_order_supply) or (!new_record? and (self.purchase_request_supplies.detect{|t| t.id == prs.id} || !prs.confirmed_purchase_order_supply) ) }
    end
    
    #TODO test this method
    def get_purchase_request_supplies_ids #get_ is useful to not replace owner_type_supplies_ids accessor
      res = []
      unconfirmed_purchase_request_supplies.each do |prs|
        if send(owner_type + "_purchase_request_supplies").detect{ |t| t.purchase_request_supply_id == prs.id } and can_add_purchase_request_supply_id?(prs.id)
          res << prs.id
        end
      end
      res.join(";")
    end
    
    #TODO test this method
    def already_associated_with_purchase_request_supply?(purchase_request_supply)
      send(owner_type + "_purchase_request_supplies").detect{ |t| t.purchase_request_supply_id == purchase_request_supply.id.to_i } && can_add_purchase_request_supply_id?(purchase_request_supply.id)
    end
  end
  
end
