class ServiceDelivery < ActiveRecord::Base
  TIME_SCALES = [nil, 'hourly', 'daily']
  
  has_permissions :as_business_object
  has_reference   :prefix => :sales
  
  has_many :orders_service_deliveries
  
  validates_presence_of :reference, :name
  
  validates_inclusion_of :time_scale, :in => TIME_SCALES
  
  validates_numericality_of :cost, :margin, :vat
  
  validates_persistence_of :reference, :time_scale, :pro_rata_billable, :if => :has_been_used?
  
  validate :validates_pro_rata_billable
  validate :validates_default_pro_rata_billing
  
  before_validation_on_create :update_reference
  
  journalize :attributes        => [ :reference, :name, :description, :time_scale, :pro_rata_billable, :default_pro_rata_billing, :cost, :margin, :vat ],
             :identifier_method => :designation
  
  has_search_index :only_attributes => [ :reference, :name, :description, :cost, :margin, :vat, :time_scale, :pro_rata_billable ],
                   :additional_attributes => { :designation => :string, :unit_price => :float, :unit_price_with_taxes => :float }
  
  def validates_pro_rata_billable
    if pro_rata_billable?
      errors.add(:pro_rata_billable, errors.generate_message(:pro_rata_billable, :not_rated)) unless rate?
    end
  end
  
  def validates_default_pro_rata_billing
    if default_pro_rata_billing?
      errors.add(:default_pro_rata_billing, errors.generate_message(:default_pro_rata_billing, :not_pro_rata_billable)) unless pro_rata_billable?
    end
  end
  
  def pro_rata_billable?
    pro_rata_billable == true || pro_rata_billable == "1" || pro_rata_billable == 1
  end
  
  def default_pro_rata_billing?
    default_pro_rata_billing == true || default_pro_rata_billing == "1" || default_pro_rata_billing == 1
  end
  
  def time_scale=(time_scale)
    time_scale = nil if time_scale == ""
    super(time_scale)
  end
  
  def valid_time_scale?
    time_scale && TIME_SCALES.include?(time_scale)
  end
  alias :rate? :valid_time_scale?
  
  def designation
    @designation = name || ""
    @designation += " (" + I18n.t("view.service_delivery.rates.#{time_scale}", :default => time_scale) + ")" if rate?
    @designation
  end
  
  def has_been_used?
    orders_service_deliveries.any?
  end
  
  def can_be_destroyed?
    !has_been_used?
  end
  
  def unit_price
    return 0.0 if cost.nil? or margin.nil?
    cost * margin
  end
  
  def unit_price_with_taxes
    return unit_price if vat.nil? or vat.zero?
    unit_price * ( 1 + (vat/100) )
  end
  
  def margin_amount
    return 0.0 if cost.nil?
    unit_price - cost
  end
end
