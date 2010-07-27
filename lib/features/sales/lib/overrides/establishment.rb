require_dependency 'lib/features/thirds/app/models/establishment'

class Establishment
  has_many :ship_to_addresses
end
