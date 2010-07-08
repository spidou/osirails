module ParcelItemsHelper
  def display_parcel_item_total(parcel_item)
    return 0 unless parcel_item.get_parcel_item_total
    parcel_item.get_parcel_item_total.to_f.to_s(2) + "&nbsp;&euro;"
  end
end
