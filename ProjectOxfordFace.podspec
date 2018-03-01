Pod::Spec.new do |s|
  s.name             = "ProjectOxfordFace"
  s.version          = "1.4.0"
  s.summary          = "Microsoft Cognitive Services - Face API iOS SDK"

  s.description  = <<-DESC
                   Integrate Microsoft Cognitive Services Face API into your iOS App!
                   DESC
  s.homepage         = "https://github.com/Microsoft/Cognitive-Face-iOS"
  s.screenshots      = "https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot1.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot2.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot3.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot4.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot5.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot6.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot7.jpg","https://github.com/Microsoft/Cognitive-Face-iOS/raw/master/SampleScreenshots/SampleScreenshot8.jpg"
  s.license          = 'MIT'
  s.author           = { "Microsoft Cognitive Services SDK" => "oxfordGithub@microsoft.com" }
  s.source           = { :git => "https://github.com/Microsoft/Cognitive-Face-iOS.git", :branch => "master", :tag => '1.4.0' }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
