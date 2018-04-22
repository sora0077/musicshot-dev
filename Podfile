# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

plugin 'cocoapods-keys', {
  :project => "musicshot",
  :keys => [
    "GithubClientId",
    "GithubClientSecret"
  ]}

inhibit_all_warnings!

target 'MusicshotUtility' do
  use_frameworks!

  target 'MusicshotCore' do
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Fabric'
    pod 'Crashlytics'

    target 'MusicshotApp' do
      inherit! :search_paths

    end
  end
end
