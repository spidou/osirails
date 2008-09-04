class Document < ActiveRecord::Base
  
  belongs_to :file_type
  has_many :document_versions
  belongs_to :has_document, :polymorphic => true

  
  attr_accessor :models
  
  # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end
  
  @models = []
  @models << "Customer"
  # Add the model name inton models array
  def self.add_model(model)
    @models << model
  end
  
  def self.models
    @models
  end
  
  def self.can_have_document(model)
    if @models.include?(model)
      true
    else
      false
    end
  end
  
  def owner_class
    self.has_document.class.name
  end
  
end
