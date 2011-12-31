#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'nokogiri'


require './ui'

module Poly
  URL = {
    :connection => "https://www4.polymtl.ca/servlet/ValidationServlet",
    :schedule   => "https://www4.polymtl.ca/servlet/PresentationHorairePersServlet"
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

if __FILE__ == $0
  Ui.instance.run
  
end