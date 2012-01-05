#!/usr/bin/ruby

require 'nokogiri'

xml = Nokogiri::XML(File.read('test/asset/xmlSchedule.xml'))
params = Hash.new
params['debutB1'] = '2012-01-09'
params['debutB2'] = '2012-01-15'
params['fin'] = '20120309'
xsl = Nokogiri::XSLT(File.read('src/google.xml.xsl'))

cal = xsl.transform(xml,params)

File.open('test/asset/cal.xml','w') {|f| cal.write_xml_to f}
