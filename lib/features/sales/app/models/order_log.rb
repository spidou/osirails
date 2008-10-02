class OrderLog < ActiveRecord::Base
  # Relationships
  belongs_to :order
  belongs_to :user
  
  # Serialization
  serialize :parameters
  
  def self.set(order, user, params)
    return false if order.nil?
    parameters = params.dup
    self.create :order_id => order.id, :user_id => user.id, :controller => parameters.delete(:controller), :action => parameters.delete(:action), :parameters => parameters
  end
end