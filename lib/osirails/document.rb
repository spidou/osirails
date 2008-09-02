class Document < ActiveRecord::Base
  
  belongs_to :file_type
  
  attr_accessor :models
  
  @models = []
  @models << "Customer"
  # Add the model name inton models array
  def self.add_model(model)
    @models << model
  end
  
  def self.models
    @models
  end
  
  def self.delete_file(file)
    
  end
  
  def self.can_have_document(model)
    if @models.include?(model)
      true
    else
      false
    end
  end
  
end
