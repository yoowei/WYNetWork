#
#  Be sure to run `pod spec lint WYNetWork.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#


Pod::Spec.new do |s|

  s.name         = "WYNetWork"
  s.version      = "1.0.0"
  s.summary      = "WYNetWork基于AFNetWorking 3.1.0重新封装的一款轻量级网络工具。 采用面向对象的方式更加符合开发习惯。"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
WYNetWork基于AFNetWorking 3.1.0重新封装的一款轻量级网络工具。 采用面向对象的方式更加符合开发习惯。
                   DESC

  s.homepage     = "https://github.com/yoowei"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "yoowei" => "wyhist2012@126.com" }
  s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/yoowei/WYNetWork.git", :tag => "#{s.version}" }
  s.source_files  = "WYNetWork", "WYNetWork/**/*.{h,m}"
  s.dependency "AFNetworking", "~> 3.1.0"
end
