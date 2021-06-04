Pod::Spec.new do |s|
    s.name             = 'BalloonView'
    s.version          = '1.0.0'
    s.summary          = 'A highly customizable BalloonView and UIBezierPath'
    s.homepage         = 'https://github.com/AndreasVerhoeven/BalloonView'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Andreas Verhoeven' => 'cocoapods@aveapps.com' }
    s.source           = { :git => 'https://github.com/AndreasVerhoeven/BalloonView.git', :tag => s.version.to_s }
    s.module_name      = 'BalloonView'

    s.swift_versions = ['5.0']
    s.ios.deployment_target = '11.0'
    s.source_files = 'Sources/*.swift'
end
