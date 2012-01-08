require 'poly'
require 'poly/trimester'
require 'poly/course'

class Poly::Schedule
  include Poly
  attr_reader :trimester
 
  # Trimesters : Hash of the possible trimesters {:id => :label}
  # postParams : PostParams obtained from the connection
  def initialize(auth,trimester)
    @params = auth.postParams
    @trimesters = auth.trimesters
    
    @trimester = Poly::Trimester.fromYAML(trimester)
    
    get(trimester)
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
  
  def get(trimester)
    raise "Invalid trimester" unless trimesterValid?(trimester)
    
    @params['trimestre'] = trimester
    @response = fetch(Poly::URL[:schedule],@params)
  end
  
  def trimesterValid?(id)
    return @trimesters.has_key?(id.to_s)
  end
end
