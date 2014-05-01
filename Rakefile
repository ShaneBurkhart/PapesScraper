PAPES_API_URL = "https://www.papesinc.com/pls/papes/ext"
INVENTORY_CSV_FILENAME = "inventory.csv"
UPDATED_INVENTORY_CSV_FILENAME = "updated_inventory.csv"

task :default => [:update_bow_inventory, :update_bow_meta_data]

desc "Completely update bow inventory"
task :update_bows => [:update_bow_inventory, :update_bow_meta_data] do
  puts "Updating bows..."
end

desc "Update bow inventory."
task :update_bow_inventory do
  require "net/http"
  require "net/https"

  puts "Updating bow inventory..."

  prods = products
  changes = 0

  current_inventory = parse_inventory_response(papes_response(inventory_query_xml(prods)))

  CSV.open(File.join(File.dirname(__FILE__), INVENTORY_CSV_FILENAME), "wb") do |csv|
    csv << prods.first.headers

    prods.each do |old|
      current_inventory.each do |updated|
        if(old["Variant SKU"] == updated["prodid"])
          changes += 1 if old["Variant Inventory Qty"] != updated["quantity"]
          old['Variant Inventory Qty'] = (updated["quantity"].to_i < 0) ? 0 : updated["quantity"]
          break
        end
      end
      csv << old
    end

  end

  puts "Bows updated: #{changes}"
  puts "Done updating bow inventory."
end


desc "Update bow meta data. Compiles from options"
task :update_bow_meta_data do
  puts "Updating bow meta data..."

  prods = products

  CSV.open(File.join(File.dirname(__FILE__), INVENTORY_CSV_FILENAME), "wb") do |csv|
    csv << prods.first.headers
    prods.each do |p|
      # Bulk update of fixed fields
      p["Published"] = "TRUE"
      p["Option1 Name"] = "Camo"
      p["Option2 Name"] = "Hand"
      p["Option3 Name"] = "Draw Weight"
      p["Variant Inventory Tracker"] = "shopify"
      p["Variant Inventory Policy"] = "deny"
      p["Variant Fulfillment Service"] = "manual"
      p["Variant Requires Shipping"] = "TRUE"
      p["Variant Taxable"] = "TRUE"
      p["Gift Card"] = "FALSE"

      csv << p
    end
  end

  puts "Done updating bow meta data"
end

def products # Gets products from csv file.  Returns CSV::Row
  require "csv"
  p = []
  CSV.foreach(File.join(File.dirname(__FILE__), INVENTORY_CSV_FILENAME), headers: true) do |row|
    p << row
  end
  p
end

def parse_inventory_response(i_res) # Parses the XML returned by Pape's inventory query
  require "nokogiri"
  doc = Nokogiri::XML(i_res)
  items = doc.xpath("//inventory/itemlist/item")
  items.map do |item|
    t = {}
    item.keys.each{ |key| t[key] = item[key] }
    t
  end
end

def papes_response(xml) # Executes request from Pape's API
  uri = URI.parse(PAPES_API_URL)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path)
  request.body = "data=" + xml
  http.request(request).body
end

def inventory_query_xml(prods) # Creates XML for Pape's API inventory query
  s = "\n"
  prods.each{|p| s += "<item prodid=\"#{p["Variant SKU"]}\"/>\n"}
  [ '<?xml version="1.0" encoding="utf-8" ?>',
    '<inventory>',
      '<ctid>5B15B4E19BAD45B7920ACB4A4064F234</ctid>',
      '<itemlist>',
        s,
      '</itemlist>',
    '</inventory>'
  ].join("\n")
end
