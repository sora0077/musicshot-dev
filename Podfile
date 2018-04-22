# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

plugin 'cocoapods-keys', {
  :project => "musicshot",
  :keys => [
    "GithubClientId",
    "GithubClientSecret"
  ]}

inhibit_all_warnings!

abstract_target 'Musicshot' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Fabric'
  pod 'Crashlytics'

  target 'MusicshotApp' do
  end

  target 'MusicshotCore' do
  end
end
