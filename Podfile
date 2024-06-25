
target 'MediaBook' do
  platform :ios, '18.0'
  use_frameworks!
  
  pod 'CloudCore', :path => '../../Libraries/CloudCore/'
  
  pod 'Viewer', :git => 'https://github.com/deeje/Viewer.git', :branch => 'feature/4.4'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
        end
    end
end
