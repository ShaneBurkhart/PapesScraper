require "./src/inventory_manager.rb"

module BowFormatter

  def update_meta_data
    read_products unless @products != nil #Check if there are products read
    @products.each do |p|
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

      if p["Title"] != ""
        filename = File.join(File.dirname(__FILE__), "../descriptions", p["Handle"]) + ".html"
        File.open(filename, "w"){} unless File.file?(filename)

        p["Body (HTML)"] = File.read(filename).gsub("\n", " ")
      end

      image_file = "#{p["Handle"]} #{p["Option1 Value"]}.#{self.class::IMAGE_EXT}".downcase.gsub(" ", "-").gsub("_", "-")
      p["Image Src"] = "http://bowhuntersuppliesimages.herokuapp.com/images/#{image_file}"
    end
  end

end

class PSEBowsManager
  include InventoryManager
  include BowFormatter
  INVENTORY_CSV_FILENAME = "pse_bows.csv"
  ITEM_NAME = "PSE Bows"
  IMAGE_EXT = "jpg"

  def update_meta_data
    super
    desc_prefixes = {}

    @products.each_with_index do |p, i|
      next if p["Title"] == "" #We don't need this since it doesn't have all the data
      sku_prefix = p["Variant SKU"][0..3]
      if desc_prefixes[sku_prefix].nil?
        desc_prefixes[sku_prefix] = p["Title"]
        (0..i).each do |index|
          t = @products[index]
          if t["Variant SKU"].start_with?(sku_prefix)
            t["Image Alt Text"] = "#{desc_prefixes[sku_prefix]}. #{t["Option2 Value"]} handed. #{t["Option3 Value"]} draw weight. #{t["Option1 Value"]} camo."
          end
        end
      else
        p["Image Alt Text"] = "#{desc_prefixes[sku_prefix]}. #{p["Option2 Value"]} handed. #{p["Option3 Value"]} draw weight. #{p["Option1 Value"]} camo."
      end
    end

  end
end

class DiamondBowsManager
  include InventoryManager
  include BowFormatter
  INVENTORY_CSV_FILENAME = "diamond_bows.csv"
  ITEM_NAME = "Diamond Bows"
  IMAGE_EXT = "png"

  def update_meta_data
    super
    desc_prefixes = {}

    @products.each_with_index do |p, i|
      next if p["Title"] == "" #We don't need this since it doesn't have all the data
      sku_prefix = p["Variant SKU"][0..4]
      if desc_prefixes[sku_prefix].nil?
        desc_prefixes[sku_prefix] = p["Title"]
        (0..i).each do |index|
          t = @products[index]
          if t["Variant SKU"].start_with?(sku_prefix)
            t["Image Alt Text"] = "#{desc_prefixes[sku_prefix]}. #{t["Option2 Value"]} handed. #{t["Option3 Value"]} draw weight. #{t["Option1 Value"]} camo."
          end
        end
      else
        p["Image Alt Text"] = "#{desc_prefixes[sku_prefix]}. #{p["Option2 Value"]} handed. #{p["Option3 Value"]} draw weight. #{p["Option1 Value"]} camo."
      end
    end

  end
end
