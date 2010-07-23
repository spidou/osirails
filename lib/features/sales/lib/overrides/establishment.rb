require_dependency 'lib/features/thirds/app/models/establishment'

Establishment.class_eval do
  has_many :ship_to_addresses
end
