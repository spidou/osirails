class SubcontractorRequest < ActiveRecord::Base
  has_permissions :as_business_object
  has_documents :quote
  
  belongs_to :survey_step
  belongs_to :subcontractor
  
  has_attached_file :attachment,
                    :path => ":rails_root/assets/sales/:class/:attachment/:id.:extension",
                    :url  => "/subcontractor_requests/:id/quote"
  
  validates_presence_of :job_needed, :subcontractor_id
  validates_presence_of :subcontractor, :if => :subcontractor_id
  
  validates_numericality_of :price
  
  validates_attachment_presence :attachment
  
  with_options :if => :attachment do |v|
    v.validates_attachment_content_type :attachment, :content_type => [ 'application/pdf', 'application/x-pdf' ],
                                                     :message      => "Le devis scanné doit être envoyé au format PDF"
    v.validates_attachment_size         :attachment, :less_than    => 5.megabytes,
                                                     :message      => "Le devis scanné ne doit pas avoir une taille supérieure à 5 MB"
  end
  
  validates_persistence_of :survey_step_id
  
  attr_accessor :should_destroy, :should_update
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
end
