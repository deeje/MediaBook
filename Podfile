
target 'MediaBook' do
  platform :ios, '16.0'
  use_frameworks!
  
  pod 'CloudCore'
  pod 'Connectivity'
  
  pod 'Viewer', :git => 'https://github.com/deeje/Viewer.git', :branch => 'feature/4.4'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
        end
    end
end
