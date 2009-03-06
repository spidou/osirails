class DocumentType < ActiveRecord::Base
  add_create_permissions_callback
  
  has_and_belongs_to_many :mime_types
  has_many :permissions, :class_name => "DocumentTypePermission", :dependent => :destroy
  
  # returns name if title is nil or empty
  def title
    (super.nil? or super.empty? ) ? "(#{name})" : super
  end
end
