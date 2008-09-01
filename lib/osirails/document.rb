class Document < ActiveRecord::Base
  
  attr_accessor :models
  
  @models = []
  # Add the model name inton models array
  def self.add_model(model)
    @models << model
  end
  
  def self.models
    @models
  end
  
  def self.delete_file(file)
    
  end
  
end
