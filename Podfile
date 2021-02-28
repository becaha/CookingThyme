platform :ios, '14.0'
use_frameworks!

target 'CookingThyme' do

  pod 'GRDB.swift'
  pod 'SwiftyJSON'

# Add the pods for any other Firebase products you want to use in your app
# For example, to use Firebase Authentication and Cloud Firestore
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'

end


post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end