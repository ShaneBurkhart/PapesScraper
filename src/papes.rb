module Papes
  CUSTOMER_ID = "5B15B4E19BAD45B7920ACB4A4064F234"
  PAPES_API_URL = "https://www.papesinc.com/pls/papes/ext"

  def self.current_inventory(prods)
    parse_inventory_response(response(inventory_query_xml(prods)))
  end

  def self.response(xml) # Executes request from Pape's API
    require "net/http"
    require "net/https"

    uri = URI.parse(PAPES_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request.body = "data=" + xml
    http.request(request).body
  end

  def self.parse_inventory_response(i_res) # Parses the XML returned by Pape's inventory query
    require "nokogiri"
    doc = Nokogiri::XML(i_res)
    items = doc.xpath("//inventory/itemlist/item")
    items.map do |item|
      t = {}
      item.keys.each{ |key| t[key] = item[key] }
      t
    end
  end

  def self.inventory_query_xml(prods) # Creates XML for Pape's API inventory query
    s = "\n"
    prods.each{|p| s += "<item prodid=\"#{p["Variant SKU"]}\"/>\n"}
    [ '<?xml version="1.0" encoding="utf-8" ?>',
      '<inventory>',
        "<ctid>#{CUSTOMER_ID}</ctid>",
        '<itemlist>',
          s,
        '</itemlist>',
      '</inventory>'
    ].join("\n")
  end

end
