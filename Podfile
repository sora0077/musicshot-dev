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
  use_frameworks!

  target 'MusicshotUtility' do
    pod 'Fabric'
    pod 'Crashlytics'

    target 'MusicshotCore' do
      inherit! :search_paths
      pod 'Firebase/Core'
      pod 'Firebase/Auth'
      pod 'Firebase/Firestore'

      target 'MusicshotApp' do
        inherit! :search_paths
      end
    end
  end
end
