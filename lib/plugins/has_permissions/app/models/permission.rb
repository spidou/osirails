class Permission < ActiveRecord::Base
  belongs_to :role
  belongs_to :has_permissions, :polymorphic => true
  
  has_many :permissions_permission_methods, :dependent => :destroy
  has_many :permission_methods, :through => :permissions_permission_methods
  
  validates_presence_of :has_permissions_id, :has_permissions_type, :role_id
  
  def method_missing(method, *args)
    accepted_methods = permissions_permission_methods.collect{|m|m.permission_method.name} # for getters
    accepted_methods += accepted_methods.collect{|m|m + "="} # for setters
    
    return super(method, *args) unless accepted_methods.include?(method.to_s)
    
    if method.to_s.ends_with?("=")
      # dynamic setter
      value = args.first
      raise "#{method} received '#{value}' but it is an unexpected value. please send either : 0, 1, true or false" unless value == "0" or value == "1" or value == 0 or value == 1 or value == true or value == false
      permissions_permission_methods.each do |m|
        if m.permission_method.name == method.to_s.chomp("=")
          return m.update_attribute(:active, value)
        end
      end
    else
      # dynamic getter
      permissions_permission_methods.each do |m|
        return m.active if m.permission_method.name == method.to_s
      end
    end
    false
  end
  
end
