//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KiwiConfiguration.h"
//#import "KWCountType.h"
#import "KWMatcher.h"
//#import "KWMatchVerifier.h"

//@class KWMessagePattern;
//@class KWMessageTracker;

@interface KWHaveReceivedMatcher : KWMatcher

//@property (nonatomic, assign) BOOL willEvaluateMultipleTimes;

#pragma mark - Configuring Matchers

- (void)haveReceived:(SEL)aSelector;
//- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount;
//- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount;
//- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount;
- (void)haveReceived:(SEL)aSelector withArguments:(NSArray *)argumentFilters;
//- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern countType:(KWCountType)aCountType count:(NSUInteger)aCount;
//- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern andReturn:(id)aValue countType:(KWCountType)aCountType count:(NSUInteger)aCount;

@end

//@interface KWMatchVerifier(KWReceiveMatcherAdditions)
//
//#pragma mark - Verifying
//
//- (void)receive:(SEL)aSelector withArguments:(id)firstArgument, ...;
//- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount arguments:(id)firstArgument, ...;
//- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ...;
//- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ...;
//
//#pragma mark Invocation Capturing Methods
//
//- (id)receive;
//- (id)receiveWithCount:(NSUInteger)aCount;
//- (id)receiveWithCountAtLeast:(NSUInteger)aCount;
//- (id)receiveWithCountAtMost:(NSUInteger)aCount;
//
//@end
