require File.join(RAILS_ROOT, 'lib', 'initialize_feature.rb')
if conf = init(config, directory) and conf.feature.activated?
  StepManager.new(directory)
end
raise Exception, "command not found: 'xpath'. It seems xpath is missing, please install it and retry (http://osirails.spidou.com/wiki/doku.php?id=osirails:developer:installation_prerequisites#apache_fop_for_pdf_generation)" unless File.exists?(`which xpath`.chomp)
require 'product_base'
