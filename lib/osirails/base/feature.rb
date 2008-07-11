# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

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
      end
      
      def installed?        
      end
      
      def activated?
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
