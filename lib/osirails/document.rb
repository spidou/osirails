class Document
  include Permissible
  
  def self.bonbon(param)
    tableau = ["test"]
    case param
    when *["lol", "non"] + tableau
      puts "ok"
    end
  end
end