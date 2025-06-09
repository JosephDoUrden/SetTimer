#!/usr/bin/env ruby

# Script to update iOS project configuration
# Run with: ruby ios/update_ios_config.rb

require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Update deployment target to iOS 12.0
project.targets.each do |target|
  if target.name == 'Runner'
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'  # iPhone only
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.settimer.settimer'
      config.build_settings['DEVELOPMENT_TEAM'] = '' # Add your team ID here
      config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    end
  end
end

project.save

puts "iOS project configuration updated successfully!"
puts "Remember to:"
puts "1. Set your Apple Developer Team ID in Xcode"
puts "2. Configure code signing"
puts "3. Test on physical device"
