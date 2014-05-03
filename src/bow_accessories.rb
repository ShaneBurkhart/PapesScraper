require "./src/inventory_manager.rb"

module AccessoryFormatter

  def update_meta_data
    read_products unless @products != nil #Check if there are products read
    @products.each do |p|
      p["Published"] = "TRUE"
      p["Variant Inventory Tracker"] = "shopify"
      p["Variant Inventory Policy"] = "deny"
      p["Variant Fulfillment Service"] = "manual"
      p["Variant Requires Shipping"] = "TRUE"
      p["Variant Taxable"] = "TRUE"
      p["Gift Card"] = "FALSE"
      p["Tags"] = "#{p["Type"]}"

      if p["Title"] != nil and p["Title"] != ""
        filename = File.join(File.dirname(__FILE__), "../descriptions", p["Vendor"].downcase(), p["Type"].downcase().gsub(" ", "_"), p["Handle"]) + ".html"
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
      p["Image Alt Text"] = p["Title"]

      p["Option1 Name"] = nil
      p["Option1 Value"] = nil
    end

  end
end

class QuiversManager
  include InventoryManager
  include AccessoryFormatter
  INVENTORY_CSV_FILENAME = "quivers.csv"
  ITEM_NAME = "Quivers"
  IMAGE_EXT = "png"

  def update_meta_data
    super
    desc_prefixes = {}

    @products.each_with_index do |p, i|
      p["Image Alt Text"] = "#{p["Title"]}. #{p["Option1 Value"]} Camo."
      p["Option2 Name"] = nil
      p["Option2 Value"] = nil
      p["Option3 Name"] = nil
      p["Option3 Value"] = nil
    end

  end
end
