//
// Matcher for checking the order of messages sent to a test spy.
//
// The "haveReceived:before:" matcher passes if at least one instance of the
// first message has been received by the test spy before it receives an
// instance of a second message type. The test fails if either the order is
// reversed or the first messages was not received at all. However, the test
// does *not* fail if the second message is not received; read this test as:
// "the first message must have been before the second, if the second was
// received at all". If you need to verify that the second message was also
// received, test for that separately.
//
// The "before" test also passes even if additional instances of the first
// message type are received after the first instance of the second message
// type; again, test separately if the number of each message type matters,
// or use one of the "after" tests along with +shouldNot+ to verify that no
// further messages arrived later.
//
// Currently, the matcher can only compare the order of messages sent to a
// single instance, not messages sent to two different instances.
//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

@interface KWHaveReceivedInOrderMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)haveReceived:(SEL)aSelector before:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector afterFirst:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector afterLast:(SEL)anotherSelector;

@end
