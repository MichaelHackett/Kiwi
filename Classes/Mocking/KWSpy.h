//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWMock.h"

@class KWMessagePattern;


@interface KWSpy : KWMock

#pragma mark - Initializing
- (id)initForClass:(Class)aClass;
- (id)initForProtocol:(Protocol *)aProtocol;
+ (id)spyForClass:(Class)aClass;
+ (id)spyForProtocol:(Protocol *)aProtocol;

#pragma mark - Recording messages
- (void)recordInvocation:(NSInvocation *)anInvocation;
- (void)clearRecordedInvocations;  // intentionally named to avoid conflicts with mocked classes

#pragma mark - Verification
- (NSUInteger)countOfReceivedMessagesMatchingPattern:(KWMessagePattern *)aMessagePattern;
- (NSIndexSet*)indexesOfReceivedMessagesMatchingPattern:(KWMessagePattern *)aMessagePattern;

@end
