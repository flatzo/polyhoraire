#encoding: UTF-8
require 'polyhoraire'

class Poly::Auth
  include Poly
  
  def initialize
    @postParams = Hash.new
    @trimesters = Hash.new
  end

  def connect(user, password, bday)
    params = {
      "code" => user,
      "nip" => password,
      "naissance" => bday }
    response = fetch(Poly::URL[:connection],params)
    extractInformation(response)
    setStatus(response)
  end
  
  def connected? 
    return @connected
  end
  

  def credentialsValid?(user,password,bday)
    connect(user,password,bday)
    return connected?
  end
  
  
  # Getters
  def postParams
    return @postParams
  end
  def trimesters
    return @trimesters
  end
  def error
    return @error
  end
  
  
  
  private
  

  
  def extractInformation(response)
    doc = Nokogiri::HTML(response.body.to_s)  
    @trimesters = extractTrimesters(doc)
    @postParams = extractPostParams(doc)
  end
  
  def extractTrimesters(doc)
    trimesterList = doc.xpath("//select[@name = 'selTrimHorPers']/option")
    
    trimesters = Hash.new()
    trimesterList.each do |node|
      trimesters[node.get_attribute(:value)] = node.content
    end
    return trimesters
  end
  
  def extractPostParams(doc)
    hiddenFields = doc.xpath("//input[@name != 'trimestre']")
    
    postParams = Hash.new()
    hiddenFields.each do |node|
      postParams[node.get_attribute(:name)] = node.get_attribute(:value)
    end
    return postParams
  end
  
  
  
  
  
  
  def setStatus(response)
    doc = Nokogiri::HTML(response.body.to_s)  
    node = doc.xpath("//font[contains(string(.),'Le système est temporairement hors d')]")
    raise 'Maintenance du dossier etudiant' unless node.empty?
    nodes = doc.xpath("//center/font[@color = '#FF0000']")
    if nodes.empty?
      @connected = true
    else
      @connected = false
      
      # Extract the error number and message
      @error = extractError(nodes.first)
      raise "Not connected"
    end
  end
  
  def extractError(node)
    error = node.content
    error.delete! ")"
    splitted = error.split("(")
    
    error = Hash.new
    error[:number] = splitted[1]
    error[:message] = splitted[0]
    
    return error
  end
end

