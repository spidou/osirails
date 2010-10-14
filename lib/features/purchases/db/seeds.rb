require 'lib/seed_helper'

# default purchases priorities
PurchasePriority.create! :name => "Critique"
PurchasePriority.create! :name => "Haute"
PurchasePriority.create! :name => "Normal", :default => true
PurchasePriority.create! :name => "Basse"



