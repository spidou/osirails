require File.join(directory, '../initialize.rb')
init(config, directory)

require 'form_options_helper'
ActionController::Base.helper ActionView::Helpers::FormOptionsHelper
#require 'action_view/helpers/instance_tag'
#require 'action_view/helpers/form_builder'