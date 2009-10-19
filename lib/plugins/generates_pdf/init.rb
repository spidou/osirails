require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
init(config, directory, "generates_pdf")

require 'fop'
require 'generates_pdf_helper'
 
ActionController::Base.send(:include, GeneratesPdfHelper)

