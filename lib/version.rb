module Osirails
  VERSION = File.read("#{RAILS_ROOT}/VERSION").strip
  
  class << self
    def version
      VERSION
    end
  end
end
