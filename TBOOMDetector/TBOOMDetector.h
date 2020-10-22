//
//  TBOOMDetector.h
//  OOMDetector
//
//  Created by Jesse Crocker on 8/31/15.
//  Copyright (c) 2015 Trailbehind. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBTerminationType) {
  TBTerminationTypeUnknown = -1,
  TBTerminationTypeAppLaunchAfterFirstInstall,
  TBTerminationTypeAppUpdate,
  TBTerminationTypeExit,
  TBTerminationTypeCrash,
  TBTerminationTypeTerminate,
  TBTerminationTypeOSUpdate,
  TBTerminationTypeDebugger,
  TBTerminationTypeForegroundOom,
  TBTerminationTypeBackgroundOom
};

@interface TBOOMDetector : NSObject

@property (nonatomic, readonly) TBTerminationType lastTerminationType;
@property (nonatomic, readonly) BOOL appWasBackgroundedOnExit;

- (instancetype)initWithDirectory:(NSString*)directory
                       crashCheck:(BOOL (^)(void))crashCheck
                         callback:(void (^)(TBTerminationType terminationType))callback;
- (void)logAbort;
- (void)logExit;

+ (NSString*)stringFromTBTerminationType:(TBTerminationType)terminationType;

@end
