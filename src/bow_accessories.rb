require "./src/inventory_manager.rb"

module AccessoryFormatter

  def update_meta_data
    read_products unless @products != nil #Check if there are products read
    @products.each do |p|
      p["Published"] = "TRUE"
      p["Option1 Name"] = ""
      p["Option1 Value"] = ""
      p["Option2 Name"] = ""
      p["Option2 Value"] = ""
      p["Option3 Name"] = ""
      p["Option3 Value"] = ""
      p["Variant Inventory Tracker"] = "shopify"
      p["Variant Inventory Policy"] = "deny"
      p["Variant Fulfillment Service"] = "manual"
      p["Variant Requires Shipping"] = "TRUE"
      p["Variant Taxable"] = "TRUE"
      p["Gift Card"] = "FALSE"
      p["Tags"] = "#{p["Type"]}"

      if p["Title"] != nil and p["Title"] != ""
        filename = File.join(File.dirname(__FILE__), "../descriptions", p["Vendor"].downcase(), p["Handle"]) + ".html"
        File.open(filename, "w"){} unless File.file?(filename)

        p["Body (HTML)"] = File.read(filename).gsub("\n", " ")
      end

      image_file = "#{p["Handle"]}.#{self.class::IMAGE_EXT}".downcase.gsub(" ", "-").gsub("_", "-")
      p["Image Src"] = "http://bowhuntersuppliesimages.herokuapp.com/images/#{image_file}"
    end
  end

end

class BowSightsManager
  include InventoryManager
  include AccessoryFormatter
  INVENTORY_CSV_FILENAME = "bow_sights.csv"
  ITEM_NAME = "Bow Sights"
  IMAGE_EXT = "png"

  def update_meta_data
    super
    desc_prefixes = {}

    @products.each_with_index do |p, i|
      next if p["Title"] == "" #We don't need this since it doesn't have all the data
      p["Image Alt Text"] = p["Title"]
    end

  end
end
