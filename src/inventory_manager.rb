module InventoryManager
  MASTER_INVENTORY_CSV_FILENAME = "master_inventory.csv"

  def read_products # Gets products from csv file.  Returns CSV::Row
    require "csv"
    @products = []
    CSV.foreach(inventory_filepath, headers: true) do |row|
      @products << row
    end
  end

  def update
    read_products
    puts "Updating #{self.class::ITEM_NAME} meta data..."
    update_meta_data
    puts "Updating #{self.class::ITEM_NAME} quantities..."
    n = update_inventory
    save
    return n
  end

  def update_inventory
    read_products unless @products != nil #Check if there are products read

    papes_inventory = Papes::current_inventory(@products) #Get Pape's inventory
    changes = 0

    @products.each do |old|
      papes_inventory.each do |updated|
        if(old["Variant SKU"] == updated["prodid"])
          changes += 1 if old["Variant Inventory Qty"] != updated["quantity"]
          old['Variant Inventory Qty'] = (updated["quantity"].to_i < 0) ? 0 : updated["quantity"]
          break
        end
      end
    end
    puts "#{self.class::ITEM_NAME} updated: #{changes}"
    changes
  end

  def save
    return if @products == nil #Nothing to save
    CSV.open(inventory_filepath, "wb") do |csv|
      csv << @products.first.headers
      @products.each{ |p| csv << p }
    end
  end

  def inventory_filepath
    File.join(File.dirname(__FILE__), "../inventories", self.class::INVENTORY_CSV_FILENAME)
  end

  def self.compile
    puts "Compiling inventory files..."
    File.open(File.join(File.dirname(__FILE__), "..", MASTER_INVENTORY_CSV_FILENAME), "wb") do |file|
      Dir.foreach(File.join(File.dirname(__FILE__), "../inventories")) do |filename|
        next if filename == "." or filename == ".."
        file << File.read(File.join(File.dirname(__FILE__), "../inventories", filename))
      end
    end
    puts "Inventories compiled as '#{MASTER_INVENTORY_CSV_FILENAME}'"
  end

end


