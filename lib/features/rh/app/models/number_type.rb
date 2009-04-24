class NumberType < ActiveRecord::Base

  has_search_index  :only_attributes => ["id","name"]#,
                    #:additional_attributes => {"name" => "string"}

  has_many :numbers

  # Validations
  validates_presence_of :name
end
