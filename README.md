# TBOOMDetector
Detect Out Of Memory events in an iOS app by process of elimination. If we can't figure out why the app is relaunching, it must have been the OOM Killer. For a complete explanation read [this excellent blog post from Facebook](https://code.facebook.com/posts/1146930688654547/reducing-fooms-in-the-facebook-ios-app/).

Requires crashlytics for detecting crashes.

Example:
```objc
TBOOMDetector *oomDetector = [[TBOOMDetector alloc] initWithCrashlyticsApiKey:@"..."
  directory:directory 
   callback:^(TBTerminationType terminationType) {
      if(terminationType == TBTerminationTypeBackgroundOom) {
        DDLogError(@"Detected Background OOM");
        [Answers logCustomEventWithName:@"OOM Background Crash"
                       customAttributes:nil];
      } else if(terminationType == TBTerminationTypeForegroundOom) {
        DDLogError(@"Detected Foreground OOM");
        [Answers logCustomEventWithName:@"OOM foreground Crash"
                       customAttributes:nil];
      }
}];
```
