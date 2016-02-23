Pod::Spec.new do |s|
  s.name         = "drupal-ios-sdk"
  s.version      = "4.0.1"
  s.summary      = "A framework for communicating to Drupal via an iPhone."
  s.homepage     = "https://github.com/kylebrowning/drupal-ios-sdk"
  s.author       = { "Kyle Browning" => "kylebrowning@me.com"}
  s.source       = { :git => "https://github.com/kylebrowning/drupal-ios-sdk.git", :tag => "4.0.1-alpha1" }
  s.source_files = "DIOS.swift"
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.license  = { :type => 'MPL 1.1/GPL 2.0', :file => "LICENSE" }
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
end
