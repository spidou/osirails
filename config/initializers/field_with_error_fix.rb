# Goodbye inappropriate divs!
# Thanks to enlight solutions for that one => http://www.enlightsolutions.com/articles/rails-validation-fieldwitherrors-annoyance/
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>" }