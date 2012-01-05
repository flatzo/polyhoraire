require 'poly'

class Poly::Schedule
  include Poly
 
  # Trimesters : Hash of the possible trimesters {:id => :label}
  # postParams : PostParams obtained from the connection
  def initialize(auth)
    @params = auth.postParams
    @trimesters = auth.trimesters
  end

  def get(trimester)
    raise "Invalid trimester" unless trimesterValid?(trimester)
    
    @params['trimestre'] = trimester
    @response = fetch(Poly::URL[:schedule],@params)
  end
  
  def to_xml
    to_xml_doc.to_s
  end

  def to_xml_doc
    html = @response.body.to_s
    # Too much spaces, substring-after wont work in some case if their still have trailling character '&#160;' 
    html.gsub!("&#160;","")

    doc = Nokogiri::HTML(html) do |config|
      config.noent
    end

    xsl = Nokogiri::XSLT(File.read(Poly::XSLDocs[:poly2XML]))
    
    return xsl.transform(doc)
  end
  
  def courses
    doc = to_xml_doc
    Poly::Course.from_nokogiri(doc)
  end
  
  private
  
  def trimesterValid?(id)
    return @trimesters.has_key?(id)
  end
end
