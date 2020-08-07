Pod::Spec.new do |spec|
  spec.name         = "MoneyDetector"
  spec.version      = "0.0.1"
  spec.summary      = "Detect if there is money in the image or not"
  spec.description  = <<-DESC
This CocoaPods Library helps you to detect if there is money in the image or not.If yes than returns the description.
                   DESC

  spec.homepage     = "https://iararat.am/"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Sevak Soghoyan" => "sevak.soghoyan@smartclick.ai" }
  spec.ios.deployment_target = "11.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/smartclick/money_detector_ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "MoneyDetector","MoneyDetector/**/*.{h,m,swift}"

end
