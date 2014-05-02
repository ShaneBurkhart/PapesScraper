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
    puts "\tUpdating #{self.class::ITEM_NAME} meta data"
    update_meta_data
    puts "\tUpdating #{self.class::ITEM_NAME} quantities"
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
    puts "\t#{self.class::ITEM_NAME} updated: #{changes}"
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
    CSV.open(File.join(File.dirname(__FILE__), "..", MASTER_INVENTORY_CSV_FILENAME), "wb") do |csv|
      bool = false
      Dir.foreach(File.join(File.dirname(__FILE__), "../inventories")) do |filename|
        next if filename == "." or filename == ".."
        puts "\t#{filename}"
        CSV.foreach(File.join(File.dirname(__FILE__), "../inventories", filename), headers: bool) do |row|
          csv << row
        end
        bool = true
      end
    end
    puts "Inventories compiled as '#{MASTER_INVENTORY_CSV_FILENAME}'"
  end

  def self.validate
    require "csv"

    puts "Validating master inventory"
    CSV.foreach(File.join(File.dirname(__FILE__), "..", MASTER_INVENTORY_CSV_FILENAME), headers: true) do |row|
      # Check for desc when necessary.
      puts "\t= #{row["Handle"]} needs a description." if row["Title"] != "" and row["Body (HTML)"] == ""

      # Check for image alt text.
      puts "\t= #{row["Handle"]} needs image alt text." if row["Image Alt Text"] == ""
      # Check for published.
      puts "\t= #{row["Handle"]} needs published." if row["Published"] == ""
      # Check for inventory tracker.
      puts "\t= #{row["Handle"]} needs Variant Inventory Tracker." if row["Variant Inventory Tracker"] == ""
      # Check for inventory policy.
      puts "\t= #{row["Handle"]} needs Variant Inventory Policy." if row["Variant Inventory Policy"] == ""
      # Check for fulfillment service.
      puts "\t= #{row["Handle"]} needs Variant Fulfillment Service." if row["Variant Fulfillment Service"] == ""
      # Check for requires shipping.
      puts "\t= #{row["Handle"]} needs Variant Requires Shipping." if row["Variant Requires Shipping"] == ""
      # Check for taxable.
      puts "\t= #{row["Handle"]} needs Variant Taxable." if row["Variant Taxable"] == ""
      # Check for gift card.
      puts "\t= #{row["Handle"]} needs Gift Card." if row["Gift Card"] == ""

      # Check for duplicate SKU.
      seen_sku = {}
      puts "\t= #{row["Variant SKU"]} already exists." if seen_sku[row["Variant SKU"]]
      seen_sku[row["Variant SKU"]] = true

      # Quantity can't be negative.
      puts "\t= #{row["Variant SKU"]} quantity can't be negative." if row["Variant Inventory Qty"].to_i < 0
    end
    puts "Master inventory validated"
  end


end


