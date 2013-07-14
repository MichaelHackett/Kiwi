//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import <Foundation/Foundation.h>

NSUInteger KWMaxMethodArgumentLength(NSMethodSignature* methodSignature);

NS_RETURNS_RETAINED
NSInvocation* KWCopyInvocation(NSInvocation* original);
