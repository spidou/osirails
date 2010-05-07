class HeadOffice < Establishment
  Contact.contacts_owners_models << self ## use to define the routes into routes.rb called here because the plugin is called
                                          # into Establisment so the routes are defined only for Establishment
end
