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
        @"haveReceived:afterFirst:",
        @"haveReceived:afterLast:"
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

    NSUInteger expectedMessageIndex = [self expectedMessageOrdinal];
    NSUInteger referenceMessageIndex = [self referenceMessageOrdinal];

    if (expectedMessageIndex == NSNotFound) {
        return NO;  // match message never received
    }
    if (referenceMessageIndex == NSNotFound) {
        return YES;  // reference message never received, so constraint is moot
    }
    switch (self.expectedMessagePosition) {
        case KWHaveReceivedMessageOrderBeforeFirst: {
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
    NSIndexSet* matchingIndexes =
        [self indexesOfReceivedMessagesMatchingSelector:self.expectedSelector];
    if (self.expectedMessagePosition == KWHaveReceivedMessageOrderBeforeFirst) {
        return [matchingIndexes firstIndex];
    }
    return [matchingIndexes lastIndex];
}

// Likewise for the "reference" message, being either the first or last
// occurence of a message matching the reference selector (depending on the
// the matching mode).
- (NSUInteger)referenceMessageOrdinal {
    NSIndexSet* matchingIndexes =
        [self indexesOfReceivedMessagesMatchingSelector:self.referenceSelector];
    if (self.expectedMessagePosition == KWHaveReceivedMessageOrderAfterLast) {
        return [matchingIndexes lastIndex];
    }
    return [matchingIndexes firstIndex];
}

- (NSIndexSet*)indexesOfReceivedMessagesMatchingSelector:(SEL)aSelector {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    return [self indexesOfReceivedMessagesMatchingPattern:messagePattern];
}

- (NSIndexSet*)indexesOfReceivedMessagesMatchingPattern:(KWMessagePattern*)aMessagePattern {
    // Sanity check: If matcher subject is not a test spy, stop and return an empty set.
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return [NSIndexSet indexSet];
    }
    KWSpy *spy = (KWSpy *)self.subject;

    return [spy indexesOfReceivedMessagesMatchingPattern:aMessagePattern];
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
    return [NSString stringWithFormat:@"received message %@ %@ %@",
            NSStringFromSelector(self.expectedSelector),
            [self messageOrderString],
            NSStringFromSelector(self.referenceSelector)];
}

- (NSString *)messageOrderString {
    switch (self.expectedMessagePosition) {
        case KWHaveReceivedMessageOrderBeforeFirst: {
            return @"before first";
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
