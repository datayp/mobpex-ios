Pod::Spec.new do |s|
 	s.platform = :ios	
  	s.name                           = 'MobpexSDK'
  	s.homepage = 'https://gitlab.com/datayp/MobpexSDK'
 	s.version                        = '0.7.0'
 	s.summary                        = 'Mobpex 聚合支付 SDK'
 	s.license                        = { :type => 'MIT', :file => 'LICENSE' }
	s.authors                        = { 'Jian Hu' => 'jian.hu@datayp.com' }
	s.source                         = { :git => 'https://gitlab.com/datayp/MobpexSDK.git', :tag => "v#{s.version}" }
	s.requires_arc                   = true
	s.ios.deployment_target          = '7.0'
	s.prepare_command = 'bash prepare.sh'
	s.preserve_paths = 'prepare.sh', 'libs/**/*'
	s.frameworks = 'CFNetwork', 'SystemConfiguration', 'Security', 'QuartzCore', 'CoreMotion', 'CoreGraphics', 'CoreTelephony', 'CoreText' 
	s.libraries = 'sqlite3', 'z', 'c++'
	s.vendored_frameworks = 'libs/channels/alipay/AlipaySDK.framework'
	s.vendored_libraries = 'libs/**/*.a'
	s.resources = 'libs/**/AlipaySDK.bundle'
	s.public_header_files = 'libs/mobpex/*.h'
	s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
end

