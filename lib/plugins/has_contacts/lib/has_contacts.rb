module HasContacts
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_contact(*args)
      options = (args.last.is_a?(Hash) ? args.pop : {})
      
      args.each do |key|
        key = key.to_sym if key.is_a?(String)
        raise ArgumentError, "[has_number] wrong key (#{key}), it is already used as a method of #{self.class.name}" if self.respond_to?(key)
        
        if options[:required]
          class_eval do
            validates_presence_of "#{key}_id".to_sym
            validates_presence_of "#{key}".to_sym, :if => "#{key}_id".to_sym
          end
        end 
        
        class_eval do
          
          cattr_accessor :contact_keys
          self.contact_keys ||= []
          self.contact_keys << key
          
          before_save("save_#{ key }".to_sym)
          
          belongs_to(key, :class_name => 'Contact')
          
          validate(:accept_contact_from_method)
          
          validates_associated(key.to_sym, :if => "#{ key }_should_be_validated?".to_sym)
          
          
          define_method "accept_contact_from_method" do # check if contacts are allowed
            contact = send(key)
            accept_from_method = options[:accept_from] || :all
            
            return if contact.nil? or accept_from_method == :all
            
            accepted_contacts_list = self.send(accept_from_method)
            raise "#{ accept_from_method } should return an instance of Array" unless accepted_contacts_list.kind_of?(Array)
            
            good_contact = ( contact.new_record? or accepted_contacts_list.include?(contact) )
            errors.add(key, ActiveRecord::Errors.default_error_messages[:inclusion]) unless good_contact
          end
          
          define_method "#{ key }_should_be_validated?" do
            return false if send(key).nil?
            send(key).new_record?
          end
          
          define_method "#{ key }_attributes=" do |attributes|
            send("#{ key }=", Contact.new(attributes)) # used only to add a new contact maybe will be updated to support edit in a next release
          end
          
          define_method "save_#{ key }" do
            contact = send(key)
            return if contact.nil? or !contact.new_record?
            
            contact.save(false)
            send("#{ key }_id=", contact.id) # say the contact_owner to reference the contact_id
          end
          
          def all_contacts
            contact_keys.collect { |key| send(key) }.compact
          end
          
        end
      end
      
    end
    
    def has_contacts
      
      Contact.contacts_owners_models << self ## used to define the routes into routes.rb
      
      class_eval do
        
        has_many :contacts, :as => :has_contact, :conditions => ['hidden = ? or hidden IS NULL', false]
        
        validates_associated :contacts
        after_save :save_contacts
        
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
              c.destroy
            elsif c.should_hide?
              c.hide
            elsif c.should_update?
              c.save(false)
            end
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
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasContacts)
end
