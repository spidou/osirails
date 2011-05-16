require 'lib/seed_helper'

# default services
dirg = Service.create! :name => "Direction Générale"
Service.create! :name => "Administratif et Financier", :service_parent_id => dirg.id
Service.create! :name => "Commercial",                 :service_parent_id => dirg.id

# default society activity sectors
SocietyActivitySector.create! :name => "Enseigne"
SocietyActivitySector.create! :name => "Signalétique"
