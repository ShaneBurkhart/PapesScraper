require "./src/papes.rb"
require "./src/bows.rb"
require "./src/bow_accessories.rb"

task :default => [:update_all, :compile, :validate]

desc "Completely update all inventory"
task :update_all => [:update_bows, :update_bow_accessories]


desc "Update bow inventory."
task :update_bows do
  puts "Updating bow inventory..."
  changed = 0

  changed += PSEBowsManager.new.update
  changed += DiamondBowsManager.new.update

  puts "\tBows updated: #{changed}"
  puts "Done updating bow inventory"
end

desc "Update bow accessories inventory."
task :update_bow_accessories do
  puts "Updating bow accessories inventory..."
  changed = 0

  changed += BowSightsManager.new.update
  changed += QuiversManager.new.update

  puts "\tBow accessories updated: #{changed}"
  puts "Done updating bow accessories inventory"
end

desc "Compile all files"
task :compile do
  InventoryManager::compile
end

desc "Basic validation of CSV master list"
task :validate do
  InventoryManager::validate
end
