Pod::Spec.new do |s|
  s.name         = "waterwheel"
  s.version      = "4.3.0"
  s.summary      = "A framework for communicating to Drupal via iOS, macOS, watchOS, or tvOS."
  s.homepage     = "https://github.com/acquia/waterwheel-swift"
  s.author       = { "Kyle Browning" => "kylebrowning@me.com"}
  s.source       = { :git => "https://github.com/acquia/waterwheel-swift.git", :tag => s.version }
  s.source_files = 'src/**/**/*.swift'
  s.requires_arc = true

  pch_W = <<-EOS
  #ifndef TARGET_OS_IOS
    #define TARGET_OS_IOS TARGET_OS_IPHONE
  #endif
  #ifndef TARGET_OS_WATCH
    #define TARGET_OS_WATCH 0
  #endif
  #ifndef TARGET_OS_TV
    #define TARGET_OS_TV 0
  #endif
  EOS

  s.prefix_header_contents = pch_W

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.osx.exclude_files = 'src/iOS'
  s.watchos.exclude_files = 'src/iOS'

  s.license  = { :type => 'MPL 1.1/GPL 2.0', :file => "LICENSE" }
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'ObjectMapper'
  s.dependency 'SwiftyJSON'
  s.dependency 'SwiftyUserDefaults'
end
