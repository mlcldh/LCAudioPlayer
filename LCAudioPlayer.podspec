Pod::Spec.new do |s|

  s.name         = "LCAudioPlayer"
  s.version      = "0.0.1"
  s.summary      = "音频播放器。"

  s.homepage     = "https://github.com/mlcldh/LCAudioPlayer"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author             = { "mlcldh" => "1228225993@qq.com" }

  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/mlcldh/LCAudioPlayer.git", :tag => s.version.to_s }
#  s.source_files = "LCAudioPlayer"
  # s.source_files = 'LCAudioPlayer/LCAudioPlayer.h'
  s.source_files = 'LCAudioPlayer/**/*'

  s.frameworks = 'AVFoundation', 'CoreMedia'

  s.requires_arc = true
  s.static_framework = true
  
  

end
