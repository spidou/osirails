class SummerJob < ActiveRecord::Base
  belongs_to :person
  has_many :numbers, :as => :has_number
end
