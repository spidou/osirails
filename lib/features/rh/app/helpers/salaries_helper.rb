module SalariesHelper

  def net(brut)
  # TODO code the net method to determine the net salary starting with the brut salary
    brut -= brut * 0.20 
  end

end
 
