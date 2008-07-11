# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'yaml'
 

module Osirails
  module Base
    class Feature
      @@name = ""
      @@version = ""
      @@dependencies = []
      @@conflicts = []
      @@installed = false
      @@actived = false
      
      def initialize
        config_file = File.open("config/Features/"+self.name+"/config.yml")
        config = YAML.load(config_file)
        @@name = config["name"]
        @@version = config["version"]
        @@installed = config["installed"]
        @@actived = config["activated"]
      end
      
      def installed?
        @@installed
      end
      
        def installed=
        end
        
      def activated?
        @@actived
      end
      
        def activated=
        end

      def has_dependecies?
        @@dependencies.size > 0
      end
      
      def is_dependence?
      end
      
      def has_conflicts?
        @@conflicts > 0
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
