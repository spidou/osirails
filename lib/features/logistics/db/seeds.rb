# default measure units
metre   = UnitMeasure.create! :name => "Mètre",       :symbol => "m"
mmetre  = UnitMeasure.create! :name => "Millimètre",  :symbol => "mm"
mcarre  = UnitMeasure.create! :name => "Mètre carré", :symbol => "m²"
mcube   = UnitMeasure.create! :name => "Mètre cube",  :symbol => "m³"
mlitre  = UnitMeasure.create! :name => "Millilitre",  :symbol => "mL"
litre   = UnitMeasure.create! :name => "Litre",       :symbol => "L"
watt    = UnitMeasure.create! :name => "Watt",        :symbol => "W"
kwatt   = UnitMeasure.create! :name => "Kilowatt",    :symbol => "kW"
volt    = UnitMeasure.create! :name => "Volt",        :symbol => "V"
ampere  = UnitMeasure.create! :name => "Ampère",      :symbol => "A"
mampere = UnitMeasure.create! :name => "Milliampère", :symbol => "mA"
degre   = UnitMeasure.create! :name => "Degré",       :symbol => "°"
heure   = UnitMeasure.create! :name => "Heure",       :symbol => "H"

# default supply sizes
epaisseur = SupplySize.create! :name => "Épaisseur"
diametre  = SupplySize.create! :name => "Diamètre",   :short_name => "Ø", :display_short_name => true, :accept_string => true
largeur   = SupplySize.create! :name => "Largeur",    :short_name => "l"
longueur  = SupplySize.create! :name => "Longueur",   :short_name => "L"
hauteur   = SupplySize.create! :name => "Hauteur",    :short_name => "H"
volume    = SupplySize.create! :name => "Volume"
puissance = SupplySize.create! :name => "Puissance"
tension   = SupplySize.create! :name => "Tension"
intensite = SupplySize.create! :name => "Intensité"
angle     = SupplySize.create! :name => "Angle",      :short_name => "θ"

# default supply unit measures
SupplySizesUnitMeasure.create! :supply_size_id => epaisseur.id,  :unit_measure_id => mmetre.id
SupplySizesUnitMeasure.create! :supply_size_id => diametre.id,   :unit_measure_id => mmetre.id
SupplySizesUnitMeasure.create! :supply_size_id => largeur.id,    :unit_measure_id => mmetre.id
SupplySizesUnitMeasure.create! :supply_size_id => largeur.id,    :unit_measure_id => metre.id
SupplySizesUnitMeasure.create! :supply_size_id => longueur.id,   :unit_measure_id => mmetre.id
SupplySizesUnitMeasure.create! :supply_size_id => longueur.id,   :unit_measure_id => metre.id
SupplySizesUnitMeasure.create! :supply_size_id => hauteur.id,    :unit_measure_id => mmetre.id
SupplySizesUnitMeasure.create! :supply_size_id => hauteur.id,    :unit_measure_id => metre.id
SupplySizesUnitMeasure.create! :supply_size_id => volume.id,     :unit_measure_id => litre.id
SupplySizesUnitMeasure.create! :supply_size_id => volume.id,     :unit_measure_id => mcube.id
SupplySizesUnitMeasure.create! :supply_size_id => puissance.id,  :unit_measure_id => watt.id
SupplySizesUnitMeasure.create! :supply_size_id => puissance.id,  :unit_measure_id => kwatt.id
SupplySizesUnitMeasure.create! :supply_size_id => tension.id,    :unit_measure_id => volt.id
SupplySizesUnitMeasure.create! :supply_size_id => intensite.id,  :unit_measure_id => ampere.id
SupplySizesUnitMeasure.create! :supply_size_id => intensite.id,  :unit_measure_id => mampere.id
SupplySizesUnitMeasure.create! :supply_size_id => angle.id,      :unit_measure_id => degre.id

# create calendar for equipments
Calendar.create! :name => "equipments_calendar", :title => "Planning des équipements"

## default document types for tools and tool_events (document types are created automatically when the class of the owner is parsed)
#### get mime types
pdf = MimeType.find_by_name("application/pdf")
jpg = MimeType.find_by_name("image/jpeg")
png = MimeType.find_by_name("image/png")
####
dt = DocumentType.find_or_create_by_name("legal_paper")
dt.update_attribute(:title, "Document légal")
dt.mime_types << [ pdf, jpg, png ]
dt = DocumentType.find_or_create_by_name("invoice")
dt.update_attribute(:title, "Facture")
dt.mime_types << [ pdf, jpg, png ]
dt = DocumentType.find_or_create_by_name("expence_account")
dt.update_attribute(:title, "Note de frais")
dt.mime_types << [ pdf, jpg, png ]
dt = DocumentType.find_or_create_by_name("manual")
dt.update_attribute(:title, "Manuel")
