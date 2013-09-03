//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

@interface KWHaveReceivedMatcher : KWMatcher

//@property (nonatomic, assign) BOOL willEvaluateMultipleTimes;

#pragma mark - Configuring Matchers

- (void)haveReceived:(SEL)aSelector;
- (void)haveReceived:(SEL)aSelector withCount:(NSUInteger)aCount;
- (void)haveReceived:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount;
- (void)haveReceived:(SEL)aSelector withCountAtMost:(NSUInteger)aCount;
- (void)haveReceived:(SEL)aSelector withArguments:(NSArray *)argumentFilters;
- (void)haveReceived:(SEL)aSelector withCount:(NSUInteger)aCount arguments:(NSArray *)argumentFilters;
- (void)haveReceived:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount arguments:(NSArray *)argumentFilters;
- (void)haveReceived:(SEL)aSelector withCountAtMost:(NSUInteger)aCount arguments:(NSArray *)argumentFilters;

@end

//@interface KWMatchVerifier(KWReceiveMatcherAdditions)
//
//#pragma mark - Verifying
//
// The following variations are placed in a category on KWMatchVerifier
// because the variable argument lists are not supported by the usual
// KWMatcher invocation mechanism (which uses NSInvocations, which do not
// support vararg method calls).
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
