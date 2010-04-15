class Third < ActiveRecord::Base
  belongs_to :legal_form
  
  validates_presence_of :name, :legal_form_id
  validates_presence_of :legal_form, :if => :legal_form_id
  
  validates_format_of :website, :with         => /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
                                :allow_blank  => true,
                                :message      => "L'adresse du site web ne respecte pas le format demandé"
  
  validates_uniqueness_of :name, :scope => :type
  
  RATINGS = { "0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5 }
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]                      = "Raison Sociale :"
  @@form_labels[:legal_form]                = "Forme juridique :"
  @@form_labels[:website]                   = "Site Internet :"
  @@form_labels[:created_at]                = "Créé le :"
  @@form_labels[:creator]                   = "Créé par :"
  
  def website_url
    "http://#{website}" unless website.blank?
  end
end
