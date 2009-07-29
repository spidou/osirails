module ThirdsHelper
  def contextual_search_for_customer
    contextual_search("Customer", { :activity_sector => ["name"],
                                    :legal_form      => ["name"],
                                    :contacts        => ["first_name", "last_name"],
                                    :establishments  => ["name"] })
  end
  
  def contextual_search_for_supplier
    contextual_search("Supplier", { :activity_sector => ["name"],
                                    :legal_form      => ["name"],
                                    :contacts        => ["first_name", "last_name"],
                                    :iban            => ["account_name", "bank_name", "bank_code", "branch_code", "account_number"] })
  end
end
