module HasContacts
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_contacts options = {}
      include InstanceMethods
      raise "has_contacts must be called only once" if Contact.contacts_owners_models.include?(self) # multiple calls are forbidden
      
      Contact.contacts_owners_models << self
      
      cattr_accessor :has_contacts_definitions
      
      options = { :many        => true,
                  :accept_from => :all }.merge(options)
      
      raise ArgumentError, ":many option should be true or false" if options[:many] != true and options[:many] != false
      
      self.has_contacts_definitions = options       
      
      has_many :contacts_owners, :as => :has_contact
      has_many :contacts, :source => :contact, :through => :contacts_owners
      
      after_save :save_contacts
      validates_associated :contacts
      #validates_inclusion_of :contacts, :in => :customer_contacts
      
      class_eval do
        
        def validate # check if contacts are allowed
          accept_from_method = self.class.has_contacts_definitions[:accept_from]
          return if contacts.empty? or accept_from_method == :all
          
          collection = self.send(accept_from_method)
          raise "#{accept_from_method} must return an instance of Array" unless collection.kind_of?(Array)
          
          wrong_contacts = contacts.select{ |c| !collection.include?(c) }
          #errors.add(:contacts, "contient des éléments qui ne sont pas admis") unless wrong_contacts.empty?
          errors.add(:contacts, ActiveRecord::Errors.default_error_messages[:inclusion]) unless wrong_contacts.empty?
        end
        
        def build_contact(params = {})
          self.contacts.build( {:gender => 'M' }.merge(params) )
        end
        
        def contact_attributes=(contact_attributes)
          contact_attributes.each do |attributes|
            if attributes[:id].blank?
              contacts.build(attributes)
            else
              contact = contacts.detect { |t| t.id == attributes[:id].to_i }
              contact.attributes = attributes
            end
          end
        end
        
        def save_contacts
          contacts.each do |c|
            if c.should_destroy?
              contacts.delete(c) # delete the contact from the contacts' list, but dont delete the contact itself
            elsif c.should_update?
              c.save(false)
            end
          end
        end
        
        def self.has_many_contacts?
          self.has_contacts_definitions[:many]
        end
        
      end
      
      unless options[:many]
        class_eval do
          def contact
            self.contacts.first
          end
        end
      end
      
    end
    
    def validates_contact_presence options = {}
      validates_presence_of :contacts, options
    end
    
    def validates_contact_length options = {}
      with_options :if => :contact_ids do |o|
        o.validates_length_of :contact_ids, options
      end
    end
    
  end
  
  module InstanceMethods
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasContacts)
end
