module ProductsHelper
  
  def display_product_dimensions(form, product, text_field_options = {})
    if form.form_view?
      '<span class="product_dimensions">
        <span class="product_width">' +
          '<span title="Largeur">l :</span>' + form.text_field(:width, { :value => product.width, :size => 6, :autocomplete => :off }.merge(text_field_options)) +
        '</span>' +
        '<span class="product_length">' +
          '<span title="Longueur">L :</span>' + form.text_field(:length, { :value => product.length, :size => 6, :autocomplete => :off }.merge(text_field_options)) +
        '</span>' +
        '<span class="product_height">' +
          '<span title="Hauteur">H :</span>' + form.text_field(:height, { :value => product.height, :size => 6, :autocomplete => :off }.merge(text_field_options)) +
        '</span>&nbsp;mm
      </span>'
    else
      strong(product.dimensions)
    end
  end
  
end
