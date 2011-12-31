require './poly'

class Poly::Schedule
  include Poly
 
  def initialize(trimester,postParams)
    @params = postParams
    @params['trimestre'] = trimester
    @response = fetch(Poly::URL[:schedule],@params)
  end


  def to_xml
    html = @response.body.to_s
    # Too much spaces, substring-after wont work in some case if their still have trailling &#160;
    html.gsub!("&#160;","")

    doc = Nokogiri::HTML(html) do |config|
      config.noent
    end

    xsl = Nokogiri::XSLT(File.read('./poly2XML.xsl'))
    
    return xsl.transform(doc)
  end
end
