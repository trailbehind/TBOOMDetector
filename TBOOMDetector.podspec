Pod::Spec.new do |s|

  s.name         = "TBOOMDetector"
  s.version      = "1.0"
  s.summary      = "Detect Out Of Memory events in an iOS app"

  s.description  = <<-DESC
                  Detect out of memory events by process of elimination
                   DESC

  s.homepage     = "https://github.com/trailbehind/TBOOMDetector"
  s.license      = "MIT"

  s.author             = { "TrailBehind, Inc." => "Jesse@Gaiagps.com" }
  s.social_media_url   = "http://twitter.com/gaiagps"

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/trailbehind/TBOOMDetector.git", :tag => "1.0" }

  s.source_files  = "TBOOMDetector/*.{h,m,c}"

end
