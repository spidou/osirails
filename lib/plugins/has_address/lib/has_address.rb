module HasAddress
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_address name, params = {}
      # default params
      params = { :one_or_many => :one }.merge(params)
      raise ArgumentError, "has_address expected a symbol for its first parameter 'name'" unless name.instance_of?(Symbol)
      raise ArgumentError, "has_address should have a symbol as 'one_or_many' parameter" unless params[:one_or_many].instance_of?(Symbol)
      
      #FIXME remove this class accessor one_or_many when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
      cattr_accessor :one_or_many
      self.one_or_many = params[:one_or_many]
      
      has_one name, :as => :has_address, :class_name => 'Address', :conditions => [ "has_address_key = ?", name.to_s ]
      validates_associated name
      
      define_method "#{name}_attributes=" do |attributes|
        if self.send(name).nil?
          self.send("#{name}=", self.send("build_#{name}", attributes))
        else
          self.send(name).attributes = attributes
        end
      end
      
      # FIXME call this method with no argument works but raise a warning
      # more infos here : http://www.pgrs.net/2008/12/31/strange-behavior-with-define_method-and-the-wrong-number-of-arguments
      # and here : http://benanne.net/code/?p=108
      define_method "build_#{name}" do |attributes|
        attributes ||= {}
        send( "#{name}=" , Address.new(attributes.merge({:has_address_id => self.id, :has_address_type => self.class.class_name, :has_address_key => name.to_s})) )
      end
      
      # FIXME call this method with no argument works but raise a warning
      define_method "create_#{name}" do |attributes|
        attributes ||= {}
        Address.create(attributes.merge({:has_address_id => self.id, :has_address_type => self.class.class_name, :has_address_key => name.to_s}))
      end
      
      after_save "save_#{name}".to_sym
      
      define_method "save_#{name}" do
        self.send(name).save unless self.send(name).nil?
      end
      
      class_eval do
        def full_address
          address.formatted unless address.nil?
        end
      end
    end
    
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasAddress)
end
