# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 require 'yaml'

module Osirails
  module Base
    class Feature
      protected
        @@name = ""
        @@version = ""
        @@dependencies = []
        @@conflicts = []
        @@installed = false
        @@actived = false
      
      public
        def initialize
          config_file = File.open("config/config.yml")
          config = YAML.load(config_file)
          @@name = config["name"]
        end
        
        def name
          @@name
        end
        
        def name=
          
        end
        
        def version
          @@version
        end
        
        def version=
          
        end
        
        def dependencies
          @@dependencies
        end
        
        def dependencies=
          
        end
        
        def conflicts
          @@conflicts
        end
        
        def conflicts=
          
        end

        def installed?
          @@installed
        end

        def installed=
        end
        
        def activated?
          @@activated
        end
        
        def activated=
        end

        def has_dependecies?  
        end

        def is_dependence?
        end

        def has_conflicts?
        end

        def installable?
        end

        def able_to_activate?
        end

        def able_to_deactivate?
        end

        def enable
        end

        def disable
        end

        def install
        end

        def uninstall
        end

        def remove
        end

        def check
        end
    end
  end
end
