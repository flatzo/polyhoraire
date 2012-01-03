#!/usr/bin/ruby

$: << File.expand_path(File.dirname(__FILE__))

require 'net/http'
require 'uri'
require 'nokogiri'


module Poly
  URL = {
    :connection => "https://www4.polymtl.ca/servlet/ValidationServlet",
    :schedule   => "https://www4.polymtl.ca/servlet/PresentationHorairePersServlet"
    }
    
  XSLDocs = {
    :poly2XML     => "./poly/poly2XML.xsl",
    :exportGoogle => "./google.xml.xsl"
  }
  
  def fetch(uri,params)
    url = URI.parse(uri)
    
    req = Net::HTTP::Post.new(url.path)
    req.form_data = params
    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    response = con.start {|http| http.request(req)}
  
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      return response
    else
      response.error!
    end
  end 
    
end

# Run only if the script is called directly from cli
if __FILE__ == $0
  require './cli'
  
  CLI.instance.run
end