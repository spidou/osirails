class Employee < ActiveRecord::Base
  has_one :user
  after_create :methode
  
  def pattern(pat,obj)
    retour = ""
    val = pat
    val.gsub!(/\{/,"|")
    val.gsub!(/\}/,"|")
    val = val.split("|")
    
    for i in (1...val.size) do
      if(i%2==0)
        retour += val[i]        
      else
        tmp = val[i].split(",")
        txt = tmp[0].downcase
        if obj.respond_to?(txt)  
          if tmp.size==2
            for j in (1...tmp.size)             
                if tmp[0]==tmp[0].upcase
                  tmp[0].downcase!
                  txt = obj.send(tmp[0])[0...tmp[1].to_i]
                  retour += txt.upcase
                else
                  txt = obj.send(tmp[0])[0...tmp[1].to_i]
                  retour += txt.downcase
                end 
            end 
          else
            tmp = val[i].downcase
            txt = obj.send(tmp)
            if val[i] == val[i].upcase
              retour += txt.upcase
            else
              retour += txt.downcase
            end
          end
        else
           return retour = "error in attribute name ["+ tmp[0] +"]"
        end
      end
    end
      return retour.to_s
  end
  
  def methode
    User.create(:username => pattern($pattern,self), :password =>"password")
  end 
end
