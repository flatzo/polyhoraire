#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'nokogiri'


module Poly
  
  URL = {
    :connection => "https://www4.polymtl.ca/servlet/ValidationServlet",
    :schedule   => "https://www4.polymtl.ca/servlet/PresentationHorairePersServlet"
    }
    
  XSLDocs = {
    :poly2XML     => "lib/polyhoraire/poly2XML.xsl",
    :exportGoogle => "lib/google.xml.xsl"
  }
  
  @userConfDir = 'conf'
  
  def self.userConfDir
    @userConfDir
  end
  def self.userConfDir=(value)
    @userConfDir = value
  end
  
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