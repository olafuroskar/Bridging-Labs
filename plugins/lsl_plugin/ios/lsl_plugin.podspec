#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint lsl_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'lsl_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A plugin for the Lab Streaming Layer'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Technical University of Denmark' => 's232410@dtu.dk' }

  s.source           = { :path => '.' }
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # TODO: Fetch from releases on github
  s.ios.vendored_frameworks = "lsl.xcframework"
  s.preserve_paths = "lsl.xcframework"
  s.frameworks = "lsl"
end
