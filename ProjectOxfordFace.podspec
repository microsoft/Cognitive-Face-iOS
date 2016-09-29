Pod::Spec.new do |s|
  s.name             = "ProjectOxfordFace"
  s.version          = "1.2.0"
  s.summary          = "Microsoft Project Oxford Face iOS SDK"

  s.description  = <<-DESC
                   Integrate Microsoft Project Oxford Face APIs into your iOS App!
                   DESC
  s.homepage         = "https://github.com/Microsoft/Cognitive-Face-iOS"
  s.screenshots      = "https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot1.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot2.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot3.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot4.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot5.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot6.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot7.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot8.jpg"
  s.license          = 'MIT'
  s.author           = { "Project Oxford SDK" => "oxfordGithub@microsoft.com" }
  s.source           = { :git => "https://github.com/Microsoft/Cognitive-Face-iOS.git", :branch => "master" }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ProjectOxfordFace' => ['Pod/Assets/*.png']
  }
end
