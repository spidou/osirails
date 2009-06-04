module HasContacts
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_contacts options = {}
      include InstanceMethods
      
      options = { :many               => true,
                  :validates_presence => false }.merge(options)
      
      Contact.contacts_owners_models << self
      
      has_many :contacts_owners, :as => :has_contact
      has_many :contacts, :source => :contact, :through => :contacts_owners
      
      after_save :save_contacts
      validates_associated :contacts

      if options[:validates_presence]
        validates_presence_of :contacts
      end
      
      class_eval do
        
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
        
      end
      
      if options[:many]
        class_eval do
          def has_many_contacts?
            true
          end
        end
      else
        class_eval do
          def has_many_contacts?
            false
          end
          
          def contact
            self.contacts.first
          end
        end
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
