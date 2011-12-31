require 'gdata'
require 'nokogiri'

class Google
  XSLpath = "./google.xsl" 
  
  def initialize(xmlDoc)
    toAtom(doc)
  end

  def toAtom(xmlDoc)
    xsl = Nokogiri::XSLT(File.read(XSLpath))
    xsl.transform(xmlDoc)
  end

  ## Using GData utility library : http://code.google.com/apis/gdata/articles/gdata_on_rails.html
  def send(atomDoc)
    
  end

  def auth

  end

  def auth?

  end

  def webAuth

  end

  def cliAuth

  end


end
