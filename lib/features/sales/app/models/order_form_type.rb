class OrderFormType < ActiveRecord::Base
  journalize :identifier_method => :name
end
