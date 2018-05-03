
platform :ios, '10.0'

def common
    pod 'SnapKit'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RealmSwift'
end

# Pods for PianoNote
target 'PianoNote' do
    use_frameworks!
    common
    pod 'Texture'
    pod 'SwiftyJSON'
    pod 'FBSDKLoginKit'
    pod 'CryptoSwift'
    pod 'URLEmbeddedView', :git => 'https://github.com/PianoInc/URLEmbeddedView.git'
    
    # Pods for testing
    target 'PianoNoteTests' do
        inherit! :search_paths
    end
    # Pods for UI testing
    target 'PianoNoteUITests' do
        inherit! :search_paths
    end
end

# Pods for widget
target 'widget' do
    use_frameworks!
    common
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
			config.build_settings['GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS'] = 'NO'
        end
    end
end
