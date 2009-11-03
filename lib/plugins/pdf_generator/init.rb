require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory, 'pdf_generator')

require 'fop'
require 'pdf_generator_helper'
 
ActionController::Base.send(:include, PdfGeneratorHelper)

