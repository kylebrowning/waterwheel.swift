Pod::Spec.new do |s|
  s.name         = "drupal-ios-sdk"
  s.version      = "2.1.1"
  s.summary      = "A framework for communicating to Drupal via an iPhone."
  s.homepage     = "https://github.com/workhabitinc/drupal-ios-sdk"
  s.author       = { "Kyle Browning" => "kylebrowning@me.com",
                     "Tom Kremer" => "tomkremer@me.com" }
  s.source       = { :git => "https://github.com/kylebrowning/drupal-ios-sdk.git", :tag => "2.1.1" }
  s.source_files = "*.{h,m}"
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.license  = 'MPL 1.1/GPL 2.0'
  s.dependency 'AFNetworking', '~> 2.0'

end
