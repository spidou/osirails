namespace :osirails do
  namespace :doc do
    namespace :diagram do
      desc "Generate models diagram"
      task :models => :environment do
        sh "railroad -i -l -a -m -M -v | dot -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/models.svg"
      end
      
      desc "Generate controllers diagram"
      task :controllers => :environment do
        sh "railroad -i -l -C -v | neato -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/controllers.svg"
      end
    end
    
    desc "Generate all diagrams"
    task :diagrams => %w(diagram:models diagram:controllers)
  end
end
