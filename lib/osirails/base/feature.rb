# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'yaml'
 
module Osirails
  module Base
    class Feature
      @@class_name = self.name
      @@name = ""
      @@version = ""
      @@dependencies = []
      @@conflicts = []
      @@installed = false
      @@actived = false
      
      def initialize
        puts @@class_name
        
        url = "config/features.yml"
        
        config_file = File.open(url)
        config_yaml = YAML.load(config_file)
        path = @@class_name.split("::")
        
         tmp = config_yaml[path[0]]
         
        (1...path.size).each do |i|
           tmp = tmp[path[i]]
        end 
        @@actived=tmp["actived"]
        @@installed=tmp["installed"]
       
       
        puts "Installe : " + @@installed.to_s
        puts "Activé : " + @@actived.to_s
#        File.open(url, 'w') do |out|
#          out.write(class_name_to_yaml(@@class_name))
#          out.close
#        end
      end

      def class_name_to_yaml(class_name)
        path = class_name.split("::")
        temp1 = {}
        temp2 = {}
        i = path.size - 1
        temp1[path[i]] = "true"
        while(i > 0)
          i -= 1
          temp2 = {}
          temp2[path[i]] = temp1
          temp1 = temp2
        end
        temp2.to_yaml
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
