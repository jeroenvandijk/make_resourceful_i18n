require 'ftools'
# Installs the locale files into rails locales directory
puts IO.read(File.join(File.dirname(__FILE__), 'README'))
filename = "en-EN-make_resourceful.yml"

current_dir = File.dirname(__FILE__)

source_path = File.join(current_dir, "locales", filename)
target_path = File.expand_path(File.join(current_dir, '../../../config/locales/', filename))

if File.exists?(target_path)
  puts "It looks like you already have a locale file at #{target_path}. We've left it as-is. Recommended: check #{source_path} to see if anything has changed, and update '#{filename}' accordingly."
else
  File.copy(source_path, target_path)
end
