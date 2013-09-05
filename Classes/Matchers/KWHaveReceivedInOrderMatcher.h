//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

/*

Matcher for checking the order of messages sent to a test spy.

The various forms of this matcher pass if **both** of these conditions are
true:

* the message type specified by the **first argument** (the "expected
  message") was received by the matcher's subject (which must be a test spy)
* at least one instance of that message type (if it was received more than
  once) was received either before or after some instance (the first or
  last) of a second message type (the "reference message"), as specified by
  the name and value of the second argument **if** the reference message type
  was received at all. (If the reference message was not received, the
  matcher considers this condition met. If you need to be sure that the
  reference message was also received, add a separate "haveReceived:"
  matcher for it, too.)

For example, the matcher:

    haveReceived:@selector(a) beforeFirst:@selector(b)

passes if +a+ is received at least once before +b+, or only +a+ is received.

The above conditions imply that the matcher always passes if *only* the
expected message is received, and always fails if only the reference message
is received (or if no messages are received).

Some combinations may seem of limited use, such as "beforeLast" (which does
not fail if the expected message also appears /after/ the reference message),
but might be more useful in their negative ("shouldNot") form, where the
matcher verifies that some message was *not* received in some order. For
example, turning "beforeLast" around, we can test that some message comes
*only after* another, if it was received at all. You may want to combine the
positive and negative forms to verify a strict ordering of messages.

WARNING: Do be careful about the negative forms of the special cases: If the
expected message is not received, the matcher will pass with a +shouldNot+
verifier, which is logical. However, if only the expected message is received
(and not the reference message), a +shouldNot+ form of this matcher will
always **fail**, which may not be what you expect. (After all, the expected
message actually *didn't* come before or after the reference message, if
the reference message wasn't received, and in the positive case, this matcher
always passes.) There is, unfortunately, not currently any way for a matcher
to detect whether it is being used in a positive or negative context (except
after the fact, when its failure message is being requested), so there
doesn't appear to be any way to work around this. Just be aware of it and
use an additional matcher to verify that the reference message was also
received, in conjunction with the matcher to test for ordering.

Currently, the matcher can only compare the order of messages sent to a
single instance, not messages sent to two different instances.

*/
@interface KWHaveReceivedInOrderMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)haveReceived:(SEL)aSelector beforeFirst:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector beforeLast:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector afterFirst:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector afterLast:(SEL)anotherSelector;

@end
