class Remark < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :user
  
  validates_presence_of :user_id, :text
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:text] = "Votre commentaire :"
end
