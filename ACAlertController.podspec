Pod::Spec.new do |s|

  s.name         = "ACAlertController"
  s.version      = "0.0.1"
  s.summary      = "Highly customisable but very simple replacement for UIAlertController."
  s.description  = <<-DESC
By default ACAlertController looks exactly like native UIAlertController but could be modified as you wish. ACAlertController could use any UIViews (images, controls, complex composite views, Nib-driven views, etc.) as items and buttons.
                   DESC
  s.homepage     = "https://github.com/Avtolic/ACAlertController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Avtolic"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/Avtolic/ACAlertController.git", :tag => "#{s.version}" }
  s.source_files  = "ACAlertController/*.swift"
  s.framework  = "UIKit"

end
