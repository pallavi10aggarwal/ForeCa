platform :ios, "18.0"

target 'weatherApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for weatherApp
  pod "PromiseKit", "~> 8"
  pod "JGProgressHUD"
  pod "PromiseKit/MapKit"
  pod "PromiseKit/CoreLocation"

  target 'weatherAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'weatherAppUITests' do
    # Pods for testing
  end
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
          end
      end
  end
end
