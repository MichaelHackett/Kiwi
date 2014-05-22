//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWHaveReceivedMatcher.h"
#import "KWCountType.h"
#import "KWFormatter.h"
//#import "KWInvocationCapturer.h"
#import "KWMessagePattern.h"
#import "KWObjCUtilities.h"
#import "KWSpy.h"
#import "NSInvocation+OCMAdditions.h"

//static NSString * const MatchVerifierKey = @"MatchVerifierKey";
//static NSString * const CountTypeKey = @"CountTypeKey";
//static NSString * const CountKey = @"CountKey";
//static NSString * const StubValueKey = @"StubValueKey";


// TODO: Put message capturing forms in a separate category?


@interface KWHaveReceivedMatcher ()

@property (nonatomic, strong) KWMessagePattern* messagePattern;
@property (nonatomic, assign) KWCountType messageCountType;
@property (nonatomic, assign) NSUInteger messageCount;

@end

@implementation KWHaveReceivedMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[
        @"haveReceived:",
        @"haveReceived:withCount:",
        @"haveReceived:withCountAtLeast:",
        @"haveReceived:withCountAtMost:",
        @"haveReceived:withArguments:",
        @"haveReceived:withCount:arguments:",
        @"haveReceived:withCountAtLeast:arguments:",
        @"haveReceived:withCountAtMost:arguments:"
    ];
}



#pragma mark - Matching

+ (BOOL)canMatchSubject:(id)subject {
    return ([subject isKindOfClass:[KWSpy class]]);
}

- (BOOL)evaluate {
    // sanity check --- probably should not be allowed to get here unless subject is a spy
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        [NSException raise:@"KWMatcherException" format:@"subject must be a KWSpy"];
        return NO;
    }
    NSUInteger matchCount = [self matchCount];
    switch (self.messageCountType) {
        case KWCountTypeExact:
            return matchCount == self.messageCount;
        case KWCountTypeAtLeast:
            return matchCount >= self.messageCount;
        case KWCountTypeAtMost:
            return matchCount <= self.messageCount;
        default:
            assert(0 && "unknown KWCountType in messageCountType property");
            return NO;
    }
}

- (NSIndexSet *)indexesOfMatchingInvocations {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return [NSIndexSet indexSet];
    }
    KWSpy *spy = (KWSpy *)self.subject;
    return [self.messagePattern indexesOfMatchingInvocations:spy.receivedInvocations];
}

- (NSUInteger)matchCount {
    return [[self indexesOfMatchingInvocations] count];
}

- (NSIndexSet *)indexesOfInvocationsMatchingOnlyTheSelector {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return [NSIndexSet indexSet];
    }

    KWSpy *spy = (KWSpy *)self.subject;
    KWMessagePattern *selectorOnlyPattern =
        [KWMessagePattern messagePatternWithSelector:self.messagePattern.selector];
    return [selectorOnlyPattern indexesOfMatchingInvocations:spy.receivedInvocations];
}

#pragma mark - Messages

- (NSString *)expectedMessagePatternAsString {
    return [self.messagePattern stringValue];
}

- (NSString *)expectedCountPhrase {
    return [KWFormatter phraseForCountType:self.messageCountType count:self.messageCount];
}

- (NSString *)receivedCountPhrase {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return @"unknown times";
    }
    return [KWFormatter phraseForCount:[self matchCount]];
}

- (NSString *)failureMessageForShould {
    NSMutableString *failureMessage =
        [NSMutableString stringWithFormat:@"expected subject to have received -%@ %@, but ",
         [self expectedMessagePatternAsString],
         [self expectedCountPhrase]];

    if (![self.subject isKindOfClass:[KWSpy class]]) {
        [failureMessage appendString:@"it was not a test spy"];
    } else {
        [failureMessage appendFormat:@" received it %@", [self receivedCountPhrase]];

        // If a selector-only matcher matches more methods, report the non
        // If any messages received, report the non-matching arguments in failure message.
        NSMutableIndexSet *selectorOnlyMatches =
            [[self indexesOfInvocationsMatchingOnlyTheSelector] mutableCopy];
        NSIndexSet *fullMatches = [self indexesOfMatchingInvocations];
        [selectorOnlyMatches removeIndexes:fullMatches];
        if ([selectorOnlyMatches count] > 0) {
            [failureMessage appendString:@", and instead received: "];
            KWSpy *spy = (KWSpy *)self.subject;
            NSMutableArray* invocationStrings = [NSMutableArray array];
            [selectorOnlyMatches enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                [invocationStrings addObject:[NSString stringWithFormat:@"<%@>",
                 [[spy.receivedInvocations objectAtIndex:index] invocationDescription]]];
            }];
            [failureMessage appendString:[invocationStrings componentsJoinedByString:@", "]];
        }
    }

    return [NSString stringWithString:failureMessage];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"have received message %@ %@",
            [self expectedMessagePatternAsString],
            [self expectedCountPhrase]];
}

#pragma mark - Public matcher configuration

- (void)haveReceived:(SEL)aSelector {
    [self haveReceived:aSelector withCountAtLeast:1];
}

- (void)haveReceived:(SEL)aSelector withCount:(NSUInteger)aCount {
    [self haveReceived:aSelector countType:KWCountTypeExact count:aCount];
}

- (void)haveReceived:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount {
    [self haveReceived:aSelector countType:KWCountTypeAtLeast count:aCount];
}

- (void)haveReceived:(SEL)aSelector withCountAtMost:(NSUInteger)aCount {
    [self haveReceived:aSelector countType:KWCountTypeAtMost count:aCount];
}

- (void)haveReceived:(SEL)aSelector withArguments:(NSArray *)argumentMatchers {
    [self haveReceived:aSelector withCountAtLeast:1 arguments:argumentMatchers];
}

- (void)haveReceived:(SEL)aSelector withCount:(NSUInteger)aCount arguments:(NSArray *)argumentMatchers {
    [self haveReceived:aSelector countType:KWCountTypeExact count:aCount argumentMatchers:argumentMatchers];
}

- (void)haveReceived:(SEL)aSelector withCountAtLeast:(NSUInteger)aCount arguments:(NSArray *)argumentMatchers {
    [self haveReceived:aSelector countType:KWCountTypeAtLeast count:aCount argumentMatchers:argumentMatchers];
}

- (void)haveReceived:(SEL)aSelector withCountAtMost:(NSUInteger)aCount arguments:(NSArray *)argumentMatchers {
    [self haveReceived:aSelector countType:KWCountTypeAtMost count:aCount argumentMatchers:argumentMatchers];
}


#pragma mark - Internal matcher configuration support

- (void)haveReceived:(SEL)aSelector countType:(KWCountType)aCountType count:(NSUInteger)aCount {
    [self haveReceivedMessagePattern:[KWMessagePattern messagePatternWithSelector:aSelector]
                           countType:aCountType
                               count:aCount];
}

- (void)haveReceived:(SEL)aSelector
           countType:(KWCountType)aCountType
               count:(NSUInteger)aCount
    argumentMatchers:(NSArray *)argumentMatchers
{
    NSUInteger messageArgumentCount = KWSelectorParameterCount(aSelector);
    NSUInteger actualArgumentCount = [argumentMatchers count];
    if (actualArgumentCount < messageArgumentCount) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%@ message takes %lu argument(s), but only %lu argument matcher(s) given",
                    NSStringFromSelector(aSelector),
                    (unsigned long)messageArgumentCount,
                    (unsigned long)actualArgumentCount];
    }
    KWMessagePattern *messagePattern =
        [KWMessagePattern messagePatternWithSelector:aSelector
                                     argumentFilters:argumentMatchers];
    [self haveReceivedMessagePattern:messagePattern
                           countType:aCountType
                               count:aCount];
}

- (void)haveReceivedMessagePattern:(KWMessagePattern *)aMessagePattern
                         countType:(KWCountType)aCountType
                             count:(NSUInteger)aCount
{
    self.messagePattern = aMessagePattern;
    self.messageCountType = aCountType;
    self.messageCount = aCount;
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
