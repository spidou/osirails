class Document
  include Permissible
  
  def self.bonbon
    self.can_list?(User.find(2))
  end
end