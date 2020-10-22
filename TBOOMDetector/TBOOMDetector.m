//
//  TBOOMDetector.m
//  OOMDetector
//
//  Created by Jesse Crocker on 8/31/15.
//  Copyright (c) 2015 Trailbehind. All rights reserved.
//

#import "TBOOMDetector.h"
#import "TBDebuggerUtils.h"
#import <UIKit/UIKit.h>

@interface TBOOMDetector () {
  NSString *terminationEventFile;
  NSString *backgroundStateFile;
  NSString *terminationEventFileContents;
  BOOL crashWasDetected;
  NSString *stateDirectory;
}

@end

@implementation TBOOMDetector

static NSString *AppVersionKey = @"AppVersion";
static NSString *OSVersionKey = @"OSVersion";

- (instancetype)initWithDirectory:(NSString*)directory
                       crashCheck:(BOOL (^)(void))crashCheck
                         callback:(void (^)(TBTerminationType terminationType))callback {
  self = [super init];
  if(self) {
    stateDirectory = directory;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTerminateNotification)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    terminationEventFile = [stateDirectory stringByAppendingPathComponent:@"OOMDetectorExitState.txt"];
    if([[NSFileManager defaultManager] fileExistsAtPath:terminationEventFile]) {
      terminationEventFileContents = [NSString stringWithContentsOfFile:terminationEventFile
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];
      [[NSFileManager defaultManager] removeItemAtPath:terminationEventFile
                                                 error:nil];
    } else {
      terminationEventFileContents = nil;
    }
    
    if(isApplicationAttachedToDebugger()) {
      [self logTerminationEvent:@"debugger"];
    }
    
    backgroundStateFile = [directory stringByAppendingPathComponent:@"OOMDetectorBackgroundState.bool"];
    _appWasBackgroundedOnExit = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:backgroundStateFile]) {
      [[NSFileManager defaultManager] removeItemAtPath:backgroundStateFile error:nil];
      _appWasBackgroundedOnExit = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      self->crashWasDetected = crashCheck();
      [self runChecks:callback];
    });
  }
  return self;
}


- (void)runChecks:(void (^)(TBTerminationType terminationType))callback; {
  NSString *path = [stateDirectory stringByAppendingPathComponent:@"OOMDetectorLaunchState.plist"];
  NSMutableDictionary *launchState;
  if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    launchState = [NSMutableDictionary dictionaryWithContentsOfFile:path];
  } else {
    launchState = [NSMutableDictionary dictionary];
  }
  
  TBTerminationType terminationType = TBTerminationTypeUnknown;
  if([self checkAppLaunchAfterFirstInstall:launchState]) {
    terminationType = TBTerminationTypeAppLaunchAfterFirstInstall;
  } else if([self checkAppUpdated:launchState]) {
    terminationType = TBTerminationTypeAppUpdate;
  } else if([self checkAbortOrExit]) {
    terminationType = TBTerminationTypeExit;
  } else if([self checkCrashReport]) {
    terminationType = TBTerminationTypeCrash;
  } else if([self checkDidTerminate]) {
    terminationType = TBTerminationTypeTerminate;
  } else if([self checkOsUpdate:launchState]) {
    terminationType = TBTerminationTypeOSUpdate;
  } else if ([terminationEventFileContents isEqualToString:@"debugger"]) {
    terminationType = TBTerminationTypeDebugger;
  } else {
    if(_appWasBackgroundedOnExit) {
      NSLog(@"Detected Background OOM");
      terminationType = TBTerminationTypeBackgroundOom;
    } else {
      NSLog(@"Detected Foreground OOM");
      terminationType = TBTerminationTypeForegroundOom;
    }
  }

  _lastTerminationType = terminationType;
  
  launchState[AppVersionKey] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  launchState[OSVersionKey] = [[UIDevice currentDevice] systemVersion];
  [launchState writeToFile:path atomically:YES];
  
  terminationEventFileContents = nil;

  if (callback) {
    callback(terminationType);
  }
}


- (BOOL)checkAppLaunchAfterFirstInstall:(NSDictionary*)launchState {
  NSString *lastVersion = launchState[AppVersionKey];
    
  if(lastVersion == nil) {
    return YES;
  } else {
    return NO;
  }
}


- (BOOL)checkAppUpdated:(NSDictionary*)launchState {
  NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSString *lastVersion = launchState[AppVersionKey];

  if(lastVersion == nil) {
    return NO;
  } else if([currentVersion isEqualToString:lastVersion]) {
    return NO;
  } else {
    return YES;
  }
}


- (BOOL)checkAbortOrExit {
  return terminationEventFileContents != nil &&
  ([terminationEventFileContents isEqualToString:@"exit"] ||
   [terminationEventFileContents isEqualToString:@"abort"]);
}


- (BOOL)checkCrashReport {
  return crashWasDetected;
}


- (BOOL)checkDidTerminate {
  return [terminationEventFileContents isEqualToString:@"terminate"];
}


- (BOOL)checkOsUpdate:(NSDictionary*)launchState {
  NSString *currentVersion = [[UIDevice currentDevice] systemVersion];
  NSString *lastVersion = launchState[OSVersionKey];
  
  if(lastVersion == nil) {
    return NO;
  } else if([currentVersion isEqualToString:lastVersion]) {
    return NO;
  } else {
    return YES;
  }
}


#pragma mark -
- (void)logAbort {
  [self logTerminationEvent:@"abort"];
}


- (void)logExit {
  [self logTerminationEvent:@"exit"];
}


- (void)logTerminationEvent:(NSString*)event {
  [event writeToFile:terminationEventFile
          atomically:NO
            encoding:NSUTF8StringEncoding
               error:nil];
}


#pragma mark - notifications
- (void)handleBackgroundNotification {
  [@"" writeToFile:backgroundStateFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
}


- (void)handleForegroundNotification {
  [[NSFileManager defaultManager] removeItemAtPath:backgroundStateFile error:nil];
}


- (void)handleTerminateNotification {
  [self logTerminationEvent:@"terminate"];
}


#pragma mark - class methods
+ (NSString*)stringFromTBTerminationType:(TBTerminationType)terminationType {
  switch (terminationType) {
    case TBTerminationTypeUnknown:
      return @"TBTerminationTypeUnknown";
    case TBTerminationTypeAppLaunchAfterFirstInstall:
      return @"TBTerminationTypeAppLaunchAfterFirstInstall";
    case TBTerminationTypeAppUpdate:
      return @"TBTerminationTypeAppUpdate";
    case TBTerminationTypeExit:
      return @"TBTerminationTypeExit";
    case TBTerminationTypeCrash:
      return @"TBTerminationTypeCrash";
    case TBTerminationTypeDebugger:
      return @"TBTerminationTypeDebugger";
    case TBTerminationTypeOSUpdate:
      return @"TBTerminationTypeOSUpdate";
    case TBTerminationTypeTerminate:
      return @"TBTerminationTypeTerminate";
    case TBTerminationTypeBackgroundOom:
      return @"TBTerminationTypeBackgroundOom";
    case TBTerminationTypeForegroundOom:
      return @"TBTerminationTypeForegroundOom";
  }
}


@end
