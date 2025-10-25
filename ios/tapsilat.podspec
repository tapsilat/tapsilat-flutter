Pod::Spec.new do |s|
  s.name             = 'tapsilat'
  s.version          = '0.1.1'
  s.summary          = 'Flutter SDK for Tapsilat.'
  s.description      = <<-DESC
A Flutter plugin that exposes the Tapsilat checkout SDK to iOS apps.
  DESC
  s.homepage         = 'https://github.com/tapsilat/tapsilat-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tapsilat' => 'support@tapsilat.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'tapsilat/Sources/tapsilat/**/*.swift'
  s.dependency       'Flutter'
  s.platform         = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.9'
  s.ios.xcconfig     = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift'
  }
end
