require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory, 'pdf_generator')

require 'pdf_generator_error'
require 'fop'
Fop.check_dependencies # determine if FOP is installed in the machine when the server starting

require 'pdf_generator_helper' 
ActionController::Base.send(:include, PdfGeneratorHelper)
