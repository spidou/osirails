# default contacts
contact1 = Contact.create! :first_name => "Jean-Jacques", :last_name => "Dupont",   :contact_type_id => ContactType.first.id, :email => "jean-jacques@dupont.fr", :job => "Commercial", :gender => "M"
contact2 = Contact.create! :first_name => "Pierre-Paul",  :last_name => "Dupond",   :contact_type_id => ContactType.first.id, :email => "pierre-paul@dupond.fr",  :job => "Commercial", :gender => "M"
contact3 = Contact.create! :first_name => "Nicolas",      :last_name => "Hoareau",  :contact_type_id => ContactType.first.id, :email => "nicolas@hoarau.fr",      :job => "Commercial", :gender => "M"

# create numbers and assign numbers to contacts
contact1.numbers.build(:number => "692246801", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
contact2.numbers.build(:number => "262357913", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
contact3.numbers.build(:number => "918729871", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
contact1.save!
contact2.save!
contact3.save!
