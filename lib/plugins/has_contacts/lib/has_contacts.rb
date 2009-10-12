module HasContacts
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_contact options = {}
      has_contacts options.merge({ :many => false })
    end
    
    def has_contacts options = {}
      raise "has_contacts must be called only once" if Contact.contacts_owners_models.include?(self) # multiple calls are forbidden
      include InstanceMethods
      
      Contact.contacts_owners_models << self
      
      cattr_accessor :has_contacts_definitions
      
      options = { :many        => true,
                  :accept_from => :all }.merge(options)
      
      raise ArgumentError, ":many option should be true or false" if options[:many] != true and options[:many] != false
      
      self.has_contacts_definitions = options
      
      has_many :contacts_owners, :as => :has_contact
      has_many :contacts, :source => :contact, :through => :contacts_owners
      
      after_save :save_contacts
      
      validates_contact_length :is => 1, :message => "doit contenir exactement %s contact", :if => :contacts unless options[:many]
      
      validates_associated :contacts
      
      validate :accept_contacts_from_method
      
      class_eval do
        
        def accept_contacts_from_method # check if contacts are allowed
          accept_from_method = self.class.has_contacts_definitions[:accept_from]
          return if contacts.empty? or accept_from_method == :all
          
          accepted_contacts_list = self.send(accept_from_method)
          raise "#{accept_from_method} should return an instance of Array" unless accepted_contacts_list.kind_of?(Array)
          
          wrong_contacts = contacts.select{ |c| !c.new_record? and !accepted_contacts_list.include?(c) }
          errors.add(:contacts, ActiveRecord::Errors.default_error_messages[:inclusion]) unless wrong_contacts.empty?
        end
        
        def build_contact(params = {})
          self.contacts.build( { :gender => 'M' }.merge(params) )
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
              contacts.delete(c) # delete the contact from the list, but not the contact itself
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
          
          def contact=(contact)
            self.contacts = [ contact ]
          end
        end
      end
      
    end
    
    def validates_contact_presence options = {}
      validates_presence_of :contact_ids
      
      with_options :if => :contact_ids do |o|
        o.validates_presence_of :contacts, options
      end
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
