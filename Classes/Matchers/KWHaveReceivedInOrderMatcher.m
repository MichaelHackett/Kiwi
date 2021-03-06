//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWHaveReceivedInOrderMatcher.h"
#import "KWSpy.h"
#import "KWFormatter.h"
//#import "KWInvocationCapturer.h"
#import "KWCountType.h"
#import "KWMessagePattern.h"
#import "KWObjCUtilities.h"


// Defines the expected order of one message relative to another.
typedef enum {
    KWHaveReceivedMessageOrderBeforeFirst,
    KWHaveReceivedMessageOrderBeforeLast,
    KWHaveReceivedMessageOrderAfterFirst,
    KWHaveReceivedMessageOrderAfterLast
} KWHaveReceivedMessageOrder;


@interface KWHaveReceivedInOrderMatcher ()

@property (nonatomic, assign) SEL expectedSelector;
@property (nonatomic, assign) SEL referenceSelector;
@property (nonatomic, assign) KWHaveReceivedMessageOrder expectedMessagePosition;
    // relative to reference message

@end


@implementation KWHaveReceivedInOrderMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[
        @"haveReceived:beforeFirst:",
        @"haveReceived:beforeLast:",
        @"haveReceived:afterFirst:",
        @"haveReceived:afterLast:",
        @"haveReceivedAnyMessagesBeforeFirst:",
        @"haveReceivedAnyMessagesAfterLast:"
    ];
}


#pragma mark - Matching

+ (BOOL)canMatchSubject:(id)subject {
    return ([subject isKindOfClass:[KWSpy class]]);
}

- (BOOL)evaluate {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        [NSException raise:@"KWMatcherException" format:@"subject must be a KWSpy"];
        return NO;
    }

    NSUInteger expectedMessageIndex = [self expectedMessageOrdinal];
    NSUInteger referenceMessageIndex = [self referenceMessageOrdinal];

    if (expectedMessageIndex == NSNotFound) {
        return NO;  // match message never received
    }
    if (referenceMessageIndex == NSNotFound) {
        return NO;  // reference message never received, so constraint is invalid;
                    // see class description for discussion
    }
    switch (self.expectedMessagePosition) {
        case KWHaveReceivedMessageOrderBeforeFirst:
        case KWHaveReceivedMessageOrderBeforeLast: {
            return expectedMessageIndex < referenceMessageIndex;
        }
        case KWHaveReceivedMessageOrderAfterFirst:
        case KWHaveReceivedMessageOrderAfterLast: {
            return expectedMessageIndex > referenceMessageIndex;
        }
        default: {
            assert(0 && "unknown message match order value");
            return NO;
        }
    }
}

// Returns the ordinal position (index) of the first or last occurence of the
// "expected" message within the record of all message received by the subject
// of the matcher (starting from 0). The first occurence is selected if
// testing whether the expected message appears *before* the reference message,
// while the last occurence is used if testing whether the expected message
// appears *after* the reference message. If the expected message has not been
// received at all, the method always returns +NSNotFound+.
- (NSUInteger)expectedMessageOrdinal {
    NSIndexSet* matchingIndexes = self.expectedSelector
        ? [self indexesOfReceivedMessagesMatchingSelector:self.expectedSelector]
        : [self indexesOfReceivedMessagesNotMatchingSelector:self.referenceSelector];
    switch (self.expectedMessagePosition) {
        case KWHaveReceivedMessageOrderBeforeFirst:
        case KWHaveReceivedMessageOrderBeforeLast: {
            return [matchingIndexes firstIndex];
        }
        case KWHaveReceivedMessageOrderAfterFirst:
        case KWHaveReceivedMessageOrderAfterLast: {
            return [matchingIndexes lastIndex];
        }
        default: {
            assert(0 && "unknown message match order value");
            return NO;
        }
    }
}

// Likewise for the "reference" message, being either the first or last
// occurence of a message matching the reference selector (depending on the
// the matching mode).
- (NSUInteger)referenceMessageOrdinal {
    NSIndexSet* matchingIndexes =
        [self indexesOfReceivedMessagesMatchingSelector:self.referenceSelector];
    switch (self.expectedMessagePosition) {
        case KWHaveReceivedMessageOrderBeforeFirst:
        case KWHaveReceivedMessageOrderAfterFirst: {
            return [matchingIndexes firstIndex];
        }
        case KWHaveReceivedMessageOrderBeforeLast:
        case KWHaveReceivedMessageOrderAfterLast: {
            return [matchingIndexes lastIndex];
        }
        default: {
            assert(0 && "unknown message match order value");
            return NO;
        }
    }
}

- (NSIndexSet*)indexesOfReceivedMessagesMatchingSelector:(SEL)aSelector {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    return [self indexesOfReceivedMessagesMatchingPattern:messagePattern];
}

- (NSIndexSet*)indexesOfReceivedMessagesNotMatchingSelector:(SEL)aSelector {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    return [self indexesOfReceivedMessagesNotMatchingPattern:messagePattern];
}

- (NSIndexSet*)indexesOfReceivedMessagesMatchingPattern:(KWMessagePattern*)aMessagePattern {
    // Sanity check: If matcher subject is not a test spy, stop and return an empty set.
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return [NSIndexSet indexSet];
    }
    KWSpy *spy = (KWSpy *)self.subject;

    return [aMessagePattern indexesOfMatchingInvocations:spy.receivedInvocations];
}

- (NSIndexSet*)indexesOfReceivedMessagesNotMatchingPattern:(KWMessagePattern*)aMessagePattern {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return [NSIndexSet indexSet];
    }
    KWSpy *spy = (KWSpy *)self.subject;

    return [aMessagePattern indexesOfNonmatchingInvocations:spy.receivedInvocations];
}



#pragma mark - Messages

- (NSString *)failureMessageForShould {
    // TODO: failure messages, e.g. "received it after", "did not receive it at all"
    NSString *failureReason = @"";
    return [NSString stringWithFormat:@"expected subject to have received %@ %@ %@, but %@",
            NSStringFromSelector(self.expectedSelector),
            [self messageOrderString],
            NSStringFromSelector(self.referenceSelector),
            failureReason];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"have received message %@ %@ %@",
            NSStringFromSelector(self.expectedSelector),
            [self messageOrderString],
            NSStringFromSelector(self.referenceSelector)];
}

- (NSString *)messageOrderString {
    switch (self.expectedMessagePosition) {
        case KWHaveReceivedMessageOrderBeforeFirst: {
            return @"before first";
        }
        case KWHaveReceivedMessageOrderBeforeLast: {
            return @"before last";
        }
        case KWHaveReceivedMessageOrderAfterFirst: {
            return @"after first";
        }
        case KWHaveReceivedMessageOrderAfterLast: {
            return @"after last";
        }
        default: {
            assert(0 && "unknown message match order value");
            return nil;
        }
    }
}



#pragma mark - Public matcher configuration

- (void)haveReceived:(SEL)aSelector beforeFirst:(SEL)anotherSelector {
    self.expectedSelector = aSelector;
    self.referenceSelector = anotherSelector;
    self.expectedMessagePosition = KWHaveReceivedMessageOrderBeforeFirst;
}

- (void)haveReceived:(SEL)aSelector beforeLast:(SEL)anotherSelector {
    self.expectedSelector = aSelector;
    self.referenceSelector = anotherSelector;
    self.expectedMessagePosition = KWHaveReceivedMessageOrderBeforeLast;
}

- (void)haveReceived:(SEL)aSelector afterFirst:(SEL)anotherSelector {
    self.expectedSelector = aSelector;
    self.referenceSelector = anotherSelector;
    self.expectedMessagePosition = KWHaveReceivedMessageOrderAfterFirst;
}

- (void)haveReceived:(SEL)aSelector afterLast:(SEL)anotherSelector {
    self.expectedSelector = aSelector;
    self.referenceSelector = anotherSelector;
    self.expectedMessagePosition = KWHaveReceivedMessageOrderAfterLast;
}

- (void)haveReceivedAnyMessagesBeforeFirst:(SEL)selector {
    [self haveReceived:NULL beforeFirst:selector];
}

- (void)haveReceivedAnyMessagesAfterLast:(SEL)selector {
    [self haveReceived:NULL afterLast:selector];
}




#pragma mark - Internal matcher configuration support

//- (void)haveReceived:(SEL)aSelector countType:(KWCountType)aCountType count:(NSUInteger)aCount {
//    [self haveReceivedMessagePattern:[KWMessagePattern messagePatternWithSelector:aSelector]
//                           countType:aCountType
//                               count:aCount];
//}
//
//- (void)haveReceived:(SEL)aSelector
//           countType:(KWCountType)aCountType
//               count:(NSUInteger)aCount
//    argumentMatchers:(NSArray *)argumentMatchers
//{
//    NSUInteger messageArgumentCount = KWSelectorParameterCount(aSelector);
//    NSUInteger actualArgumentCount = [argumentMatchers count];
//    if (actualArgumentCount < messageArgumentCount) {
//        [NSException raise:NSInvalidArgumentException
//                    format:@"%@ message takes %u argument(s), but only %u argument matcher(s) given",
//                    NSStringFromSelector(aSelector),
//                    messageArgumentCount,
//                    actualArgumentCount];
//    }
//    KWMessagePattern *messagePattern =
//        [KWMessagePattern messagePatternWithSelector:aSelector
//                                     argumentFilters:argumentMatchers];
//    [self haveReceivedMessagePattern:messagePattern
//                           countType:aCountType
//                               count:aCount];
//}
//
//- (void)haveReceivedMessagePattern:(KWMessagePattern *)aMessagePattern
//                         countType:(KWCountType)aCountType
//                             count:(NSUInteger)aCount
//{
//    self.messagePattern = aMessagePattern;
//    self.messageCountType = aCountType;
//    self.messageCount = aCount;
//}

@end
