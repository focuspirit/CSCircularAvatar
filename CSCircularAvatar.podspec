Pod::Spec.new do |s|
  s.name             = "CSCircularAvatar"
  s.version          = "0.0.1"
  s.summary          = "Provides an circular avatar view with progress ring"
  s.homepage         = "https://github.com/focuspirit/CSCircularAvatar"
  s.license          = 'MIT'
  s.author           = 'Shun-Kuei Chang'
  s.source           = { :git => "https://github.com/focuspirit/CSCircularAvatar.git", :tag => s.version.to_s }
  s.source_files     = 'Classes/*.{h,m}'
  s.platform     = :ios, '7.0'
  s.requires_arc = true


  s.frameworks = 'UIKit', 'QuartzCore'

  s.dependency 'pop', '~> 1.0.6'
end
