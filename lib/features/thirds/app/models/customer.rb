class Customer < Third
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  acts_as_file
  
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  acts_as_file
  
  def class_documents
    class_documents = {}
    self.documents.each do |document|
      unless class_documents.has_key?("#{document.file_type.name}")
        class_documents["#{document.file_type.name}"] = []
        class_documents["#{document.file_type.name}"] << document
      else
        class_documents["#{document.file_type.name}"] << document
      end
    end
    class_documents
  end
  
end