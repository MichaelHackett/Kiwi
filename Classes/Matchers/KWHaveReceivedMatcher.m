//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWHaveReceivedMatcher.h"
#import "KWSpy.h"
//#import "KWFormatter.h"
//#import "KWInvocationCapturer.h"
#import "KWMessagePattern.h"
//#import "KWMessageTracker.h"
//#import "KWObjCUtilities.h"
//#import "KWStringUtilities.h"
//#import "KWWorkarounds.h"
//#import "NSObject+KiwiStubAdditions.h"

//static NSString * const MatchVerifierKey = @"MatchVerifierKey";
//static NSString * const CountTypeKey = @"CountTypeKey";
//static NSString * const CountKey = @"CountKey";
//static NSString * const StubValueKey = @"StubValueKey";


// TODO: Put message capturing forms in a separate category?


@interface KWHaveReceivedMatcher ()

//@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) KWMessagePattern* messagePattern;

@end

@implementation KWHaveReceivedMatcher

//#pragma mark - Properties

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[
        @"haveReceived:",
        @"haveReceived:withArguments:"
//        @"receive:withCount:",
//        @"receive:withCountAtLeast:",
//        @"receive:withCountAtMost:",
//        @"receiveMessagePattern:countType:count:"
    ];
}

// NTS: It appears to me that -canMatchSubject: is just for selecting a
// compatible matcher when more than one implements the same matcher string.
// Returning NO does not produce an error message (except that there is
// probably some sort of 'no such matcher' error produced if no suitable
// matcher is found). Other matcher classes perform the type validation in
// the -evaluate method.


#pragma mark - Matching

- (BOOL)evaluate {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        [NSException raise:@"KWMatcherException" format:@"subject must be a KWSpy"];
        return NO;
    }
    KWSpy *spy = (KWSpy *)self.subject;

    return [spy hasReceivedMessageMatchingPattern:self.messagePattern];
}

#pragma mark - Messages

- (NSString *)expectedMessagePatternAsString {
    return [self.messagePattern stringValue];
}

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to have received -%@, but did not",
                                      [self expectedMessagePatternAsString]];
//    return [NSString stringWithFormat:@"expected subject to have received -%@ %@, but received it %@",
//                                      [self.messageTracker.messagePattern stringValue],
//                                      [self.messageTracker expectedCountPhrase],
//                                      [self.messageTracker receivedCountPhrase]];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected subject not to have received -%@, but it did",
                                      [self expectedMessagePatternAsString]];
//    return [NSString stringWithFormat:@"expected subject not to receive -%@, but received it %@",
//                                      [self.messageTracker.messagePattern stringValue],
//                                      [self.messageTracker receivedCountPhrase]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"received message %@",
            [self expectedMessagePatternAsString]];
}

#pragma mark - Configuring Matchers

- (void)haveReceived:(SEL)aSelector {
    [self haveReceivedMessagePattern:
              [KWMessagePattern messagePatternWithSelector:aSelector]];
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    // ask subject if it received a message
//    [self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:1];
}

//- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount {
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
//    [self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:aCount];
//}
//
//- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount {
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
//    [self receiveMessagePattern:messagePattern countType:KWCountTypeAtLeast count:aCount];
//}
//
//- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount {
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
//    [self receiveMessagePattern:messagePattern countType:KWCountTypeAtMost count:aCount];
//}

- (void)haveReceived:(SEL)aSelector withArguments:(NSArray *)argumentFilters {
    KWMessagePattern *messagePattern =
        [KWMessagePattern messagePatternWithSelector:aSelector
                                     argumentFilters:argumentFilters];
    [self haveReceivedMessagePattern:messagePattern];
}

- (void)haveReceivedMessagePattern:(KWMessagePattern *)aMessagePattern {
    self.messagePattern = aMessagePattern;
}

//- (void)receiveMessagePattern:(KWMessagePattern *)aMessagePattern countType:(KWCountType)aCountType count:(NSUInteger)aCount {
////#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
////    @try {
////#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
//
////    [self.subject stubMessagePattern:aMessagePattern andReturn:nil overrideExisting:NO];
////    self.messageTracker = [KWMessageTracker messageTrackerWithSubject:self.subject messagePattern:aMessagePattern countType:aCountType count:aCount];
//
////#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
////    } @catch(NSException *exception) {
////        KWSetExceptionFromAcrossInvocationBoundary(exception);
////    }
////#endif // #if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
//}

//#pragma mark - Capturing Invocations
//
//+ (NSMethodSignature *)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer methodSignatureForSelector:(SEL)aSelector {
//    KWMatchVerifier *verifier = (anInvocationCapturer.userInfo)[MatchVerifierKey];
//
//    if ([verifier.subject respondsToSelector:aSelector])
//        return [verifier.subject methodSignatureForSelector:aSelector];
//
//    NSString *encoding = KWEncodingForVoidMethod();
//    return [NSMethodSignature signatureWithObjCTypes:[encoding UTF8String]];
//}
//
//+ (void)invocationCapturer:(KWInvocationCapturer *)anInvocationCapturer didCaptureInvocation:(NSInvocation *)anInvocation {
//    NSDictionary *userInfo = anInvocationCapturer.userInfo;
//    id verifier = userInfo[MatchVerifierKey];
//    KWCountType countType = [userInfo[CountTypeKey] unsignedIntegerValue];
//    NSUInteger count = [userInfo[CountKey] unsignedIntegerValue];
//    NSValue *stubValue = userInfo[StubValueKey];
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternFromInvocation:anInvocation];
//
//    if (stubValue != nil)
//        [verifier receiveMessagePattern:messagePattern andReturn:[stubValue nonretainedObjectValue] countType:countType count:count];
//    else
//        [verifier receiveMessagePattern:messagePattern countType:countType count:count];
//}

@end

//@implementation KWMatchVerifier(KWReceiveMatcherAdditions)
//
//#pragma mark - Verifying
//
//- (void)receive:(SEL)aSelector withArguments:(id)firstArgument, ... {
//    va_list argumentList;
//    va_start(argumentList, firstArgument);
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
//    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:1];
//}
//
//- (void)receive:(SEL)aSelector withCount:(NSUInteger)aCount arguments:(id)firstArgument, ... {
//    va_list argumentList;
//    va_start(argumentList, firstArgument);
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
//    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeExact count:aCount];
//}
//
//- (void)receive:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount arguments:(id)firstArgument, ... {
//    va_list argumentList;
//    va_start(argumentList, firstArgument);
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
//    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeAtLeast count:aCount];
//}
//
//- (void)receive:(SEL)aSelector withCountAtMost:(NSUInteger)aCount arguments:(id)firstArgument, ... {
//    va_list argumentList;
//    va_start(argumentList, firstArgument);
//    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector firstArgumentFilter:firstArgument argumentList:argumentList];
//    [(id)self receiveMessagePattern:messagePattern countType:KWCountTypeAtMost count:aCount];
//}
//
//#pragma mark Invocation Capturing Methods
//
//- (NSDictionary *)userInfoForReceiveMatcherWithCountType:(KWCountType)aCountType count:(NSUInteger)aCount {
//    return @{MatchVerifierKey: self,
//                                                      CountTypeKey: @(aCountType),
//                                                      CountKey: @(aCount)};
//}
//
//- (NSDictionary *)userInfoForReceiveMatcherWithCountType:(KWCountType)aCountType count:(NSUInteger)aCount value:(id)aValue {
//    return @{MatchVerifierKey: self,
//                                                      CountTypeKey: @(aCountType),
//                                                      CountKey: @(aCount),
//                                                      StubValueKey: [NSValue valueWithNonretainedObject:aValue]};
//}
//
//- (id)receive {
//    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeExact count:1];
//    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
//}
//
//- (id)receiveWithCount:(NSUInteger)aCount {
//    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeExact count:aCount];
//    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
//}
//
//- (id)receiveWithCountAtLeast:(NSUInteger)aCount {
//    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeAtLeast count:aCount];
//    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
//}
//
//- (id)receiveWithCountAtMost:(NSUInteger)aCount {
//    NSDictionary *userInfo = [self userInfoForReceiveMatcherWithCountType:KWCountTypeAtMost count:aCount];
//    return [KWInvocationCapturer invocationCapturerWithDelegate:[KWReceiveMatcher class] userInfo:userInfo];
//}
//
//@end
