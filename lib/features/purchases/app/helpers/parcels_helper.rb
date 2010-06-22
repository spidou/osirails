module ParcelsHelper
  def display_parcel_recovered(parcel)
    return image_tag( "cross_16x16.png", :alt => "Non récupéré", :title => "Non récupéré" ) unless parcel.status == Parcel::STATUS_RECOVERED
    image_tag( "tick_16x16.png", :alt => "Récupéré", :title => "Récupéré" )
  end
end
