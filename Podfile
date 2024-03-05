
target 'MediaBook' do
  platform :ios, '17.4'
  use_frameworks!
  
  pod 'CloudCore', :path => '../../Libraries/CloudCore/'
  pod 'Connectivity'
  
  pod 'Viewer', :git => 'https://github.com/deeje/Viewer.git', :branch => 'feature/4.4'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.4'
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.4'
        end
    end
end
