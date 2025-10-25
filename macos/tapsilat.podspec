Pod::Spec.new do |s|
  s.name             = 'tapsilat'
  s.version          = '0.1.1'
  s.summary          = 'Flutter SDK for Tapsilat.'
  s.description      = <<-DESC
A Flutter plugin that exposes the Tapsilat checkout SDK to macOS apps.
  DESC
  s.homepage         = 'https://github.com/tapsilat/tapsilat-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tapsilat' => 'support@tapsilat.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'tapsilat/Sources/tapsilat/**/*.swift'
  s.dependency       'FlutterMacOS'
  s.platform         = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.9'
end
