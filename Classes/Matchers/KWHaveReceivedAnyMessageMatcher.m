//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWHaveReceivedAnyMessageMatcher.h"
#import "KWSpy.h"


@implementation KWHaveReceivedAnyMessageMatcher

#pragma mark - Getting Matcher Strings

+ (NSArray *)matcherStrings {
    return @[
        @"haveReceivedAnyMessages",
        @"haveReceivedSomeMessage"
    ];
}


#pragma mark - Matching

+ (BOOL)canMatchSubject:(id)subject {
    return ([subject isKindOfClass:[KWSpy class]]);
}

- (BOOL)evaluate {
    // TODO: remove this duplication
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        [NSException raise:@"KWMatcherException" format:@"subject must be a KWSpy"];
        return NO;
    }
    KWSpy *spy = (KWSpy *)self.subject;

    return ([spy.receivedInvocations count] > 0);
}


#pragma mark - Messages

- (NSString *)receivedMessagesPhrase {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return @"did not capture its messages";
    }
    return [NSString stringWithFormat:@"received %@", [self receivedMessageNames]];
}

- (NSString *)receivedMessageNames {
    if (![self.subject isKindOfClass:[KWSpy class]]) {
        return nil;
    }
    KWSpy *spy = (KWSpy *)self.subject;
    NSArray *receivedInvocations = spy.receivedInvocations;
    NSMutableArray* selectorNames = [NSMutableArray arrayWithCapacity:[receivedInvocations count]];
    for (NSInvocation *invocation in receivedInvocations) {
        [selectorNames addObject:NSStringFromSelector(invocation.selector)];
    }
    return [selectorNames componentsJoinedByString:@", "];
}

- (NSString *)failureMessageForShould {
    return [NSString stringWithFormat:@"expected subject to have received some message, but it received none"];
}

- (NSString *)failureMessageForShouldNot {
    return [NSString stringWithFormat:@"expected subject to have received no messages, but it %@", [self receivedMessagesPhrase]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"received any messages"];
}


#pragma mark - Public matcher configuration

// No additional configuration required.
- (void)haveReceivedAnyMessages {
}

- (void)haveReceivedSomeMessage {
}



#pragma mark - Comparison

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[self class]]) return NO;
    return [self isEqualToAnyMessageMatcher:other];
}

- (BOOL)isEqualToAnyMessageMatcher:(KWHaveReceivedAnyMessageMatcher *)otherMatcher {
    if (self == otherMatcher) return YES;
    // superclass does not currently implement isEqual:, so have to compare its fields here too
    if (self.subject != otherMatcher.subject) return NO;
    // no other properties in subclass
    return YES;
}

- (NSUInteger)hash {
    return [self.subject hash];
}

@end
