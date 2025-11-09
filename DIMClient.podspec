#
# Be sure to run `pod lib lint demo-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'DIMClient'
    s.version               = '1.0.5'
    s.summary               = 'DIMPLES'
    s.description           = <<-DESC
            DIMP Libraries for Easy Startup
                              DESC
    s.homepage              = 'https://github.com/dimchat/demo-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    # s.social_media_url    = "https://twitter.com/AlbertMoky"
    s.source                = { :git => 'https://github.com/dimchat/demo-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "11.0"
    s.ios.deployment_target = '12.0'

    s.source_files          = 'Classes', 'Classes/**/*.{h,m,mm}', 'DIMClient/DIMClient/*.h'
    # s.exclude_files       = 'Classes/Exclude'
    s.public_header_files   = 'Classes/**/*.h', 'DIMClient/DIMClient/*.h'

    # s.frameworks          = 'Security'
    # s.requires_arc        = true

    s.dependency 'DIMPlugins', '~> 1.0.9'
    s.dependency 'DIMSDK', '~> 1.0.9'
    s.dependency 'DIMCore', '~> 1.0.9'
    s.dependency 'DaoKeDao', '~> 1.0.9'
    s.dependency 'MingKeMing', '~> 1.0.9'

    s.dependency 'StarTrek', '~> 0.1.3'
    s.dependency 'FiniteStateMachine', '~> 2.3.2'
    s.dependency 'ObjectKey', '~> 0.1.3'

    # s.vendored_frameworks    = 'Frameworks/MarsGate.framework'
end
