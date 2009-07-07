class Remark < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id, :text
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:text] = "Votre commentaire :"
end
