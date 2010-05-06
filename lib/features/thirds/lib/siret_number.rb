module SiretNumber
  
  def self.included(klass)
    klass.validates_format_of :siret_number, :with        => /^([0-9]{9}|[0-9]{14})$/,
                                             :allow_blank => true,
                                             :message     => "Le numéro SIRET doit comporter 9 ou 14 chiffres"
    
    klass.form_labels.merge!({ :siret_number => "N° SIRET :" })
  end
  
  def formatted_siret_number
    "#{siret_number[0..2]} #{siret_number[3..5]} #{siret_number[6..8]}" + ( siret_number.size > 9 ? " #{siret_number[9..14]}" : "" )
  end
  
  def siret_number=(siret_number)
    super( siret_number.is_a?(String) ? siret_number.gsub(" ", "") : siret_number )
  end
  
end
