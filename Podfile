
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

