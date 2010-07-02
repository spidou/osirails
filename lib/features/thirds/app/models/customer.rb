class Customer < Third
  has_permissions :as_business_object
  has_documents   :graphic_charter
  has_address     :bill_to_address
  
  belongs_to :factor
  belongs_to :customer_solvency
  belongs_to :customer_grade
  belongs_to :creator, :class_name => 'User'
  
  has_one  :head_office
  has_many :establishments, :conditions => ['establishments.type IS NULL and ( hidden = ? or hidden IS NULL )', false]
  
  named_scope :activates, :conditions => { :activated => true }
  
  has_attached_file :logo, 
                    :styles => { :thumb => "120x120" },
                    :path   => ":rails_root/assets/thirds/customers/:id/logo/:style.:extension",
                    :url    => "/customers/:id.:extension"
  
  validates_presence_of :bill_to_address, :head_office
  
  validates_presence_of :customer_grade_id, :customer_solvency_id
  validates_presence_of :customer_grade,    :if => :customer_grade_id
  validates_presence_of :customer_solvency, :if => :customer_solvency_id
  
  with_options :if => :logo do |v|
    v.validates_attachment_content_type :logo, :content_type => [ 'image/jpg', 'image/png', 'image/jpeg' ]
    v.validates_attachment_size         :logo, :less_than => 3.megabytes
  end
  
  validates_associated :establishments, :head_office
  
  validate :validates_uniqueness_of_siret_number
  
  after_save :save_establishments, :save_head_office
  
  # for pagination : number of instances by index page
  CUSTOMERS_PER_PAGE = 25
  
  has_search_index :only_attributes    => [ :name ],
                   :only_relationships => [ :legal_form, :factor, :customer_solvency, :customer_grade, :head_office, :establishments ],
                   :main_model         => true
  
  @@form_labels[:factor]            = "Compagnie d'affacturage :"
  @@form_labels[:customer_solvency] = "Degré de solvabilité :"
  @@form_labels[:customer_grade]    = "Note relation client :"
  @@form_labels[:logo]              = "Logo :"
  
  def payment_time_limit
    customer_grade.payment_time_limit
  end
  
  def payment_method
    customer_solvency.payment_method
  end
  
  def establishment_names
    establishments.collect(&:name).uniq
  end
  
  def factorised?
    factor_id
  end
  
  def was_factorised?
    factor_id_was
  end
  
  def head_office_and_establishments
    @head_office_and_establishments ||= ( [ head_office ] + establishments ).compact
  end
  
  def contacts
    @contacts ||= head_office_and_establishments.collect(&:contacts).flatten
  end
  
  def establishment_attributes=(establishment_attributes)
    establishment_attributes.each do |attributes|
      if attributes[:id].blank?
        establishments.build(attributes)
      else
        establishment = establishments.detect { |t| t.id == attributes[:id].to_i }
        establishment.attributes = attributes
      end
    end
  end
  
  def head_office_attributes=(head_office_attributes)
    attributes = head_office_attributes.first
    if head_office.nil?
      build_head_office(attributes)
    else
      head_office.attributes = attributes 
    end
  end
  
  def save_head_office
    head_office.save(false)
  end
  
  def save_establishments
    establishments.each do |e|
      if e.should_destroy?
        e.destroy
      elsif e.should_hide?
        e.hide
      elsif e.should_update?
        e.save(false)
      end
    end
  end
  
  def activated_establishments
    establishments.select(&:activated)
  end
  
  def build_establishment(attributes = {})
    self.establishments.build(attributes)
  end
  
  def validates_uniqueness_of_siret_number
    establishments    = head_office_and_establishments
    all_siret_numbers = {}
    establishments.each{ |n| all_siret_numbers.merge!(n => n.siret_number) }
    
    message = "est déjà pris par un autre établissement (ou le siège social) de ce client"
    establishments.each do |establishment|
      other_siret_numbers = all_siret_numbers.reject{ |estab, siret_number| establishment == estab }
      establishment.errors.add(:siret_number, message) if other_siret_numbers.values.include?(establishment.siret_number)
    end
  end
end
