class LegalForm < ActiveRecord::Base
  belongs_to :third_type
  belongs_to :third
end
