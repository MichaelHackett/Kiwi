//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWMock.h"

@interface KWSpy : KWMock

#pragma mark - Initializing
- (id)initForClass:(Class)aClass;
+ (id)spyForClass:(Class)aClass;

#pragma mark - Recording messages
- (void)recordInvocation:(NSInvocation *)invocation;

#pragma mark - Verification
- (BOOL)hasReceivedMessage:(SEL)selector;

@end
