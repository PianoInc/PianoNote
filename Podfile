platform :ios, '10.0'

def common
    pod 'SnapKit'
    pod 'RealmSwift'
    pod 'RxSwift'
    pod 'RxCocoa'
end

# Pods for PianoNote
target 'PianoNote' do
    use_frameworks!
    common
    pod 'FBSDKLoginKit'
    pod 'SwiftyJSON'
    pod 'SwiftyUserDefaults'
    
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

