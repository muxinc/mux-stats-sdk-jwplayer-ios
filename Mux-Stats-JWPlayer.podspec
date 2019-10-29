Pod::Spec.new do |s|
  s.name             = 'Mux-Stats-JWPlayer'

  s.version          = '0.1.0-beta.0'
  s.source           = { :git => 'https://github.com/muxinc/mux-stats-sdk-jwplayer-ios.git',
                         :tag => "v#{s.version}" }

  s.summary          = 'The Mux Stats SDK for JWPlayer'
  s.description      = 'The Mux stats SDK connect with AVPlayer to performance analytics and QoS monitoring for video.'

  s.homepage         = 'https://mux.com'
  s.social_media_url = 'https://twitter.com/muxhq'

  s.license          = 'Apache 2.0'
  s.author           = { 'Mux' => 'ios-sdk@mux.com' }

  s.ios.deployment_target = '11.0'
  s.vendored_frameworks = 'Frameworks/iOS/fat/MUXSDKStatsJWPlayer.framework'
end
