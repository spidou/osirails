require_dependency 'app/models/service'

class Service
  has_many :memorandums_services
  has_many :memorandums, :through => :memorandums_services
end
