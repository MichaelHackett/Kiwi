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

* the message types specified by the first argument (the "expected message")
  and the second argument (the "reference message") were both received by the
  matcher's subject (which must be a test spy) at least once
* at least one instance of the expected message type was received either
  before or after some instance (the first or last) of the reference message
  type, as specified by the name and value of the second argument.

For example, the matcher:

    haveReceived:@selector(a) beforeFirst:@selector(b)

passes if +a+ is received at least once before +b+, or only +a+ is received.

Note that one implication of the above conditions is that the matcher always
fails if the reference message is not received. This was a somewhat arbitrary
decision (given that the comparison is simply invalid if there is no
reference point), but it seemed logical that the negative case (e.g.,
+[[aSpy shouldNot] haveReceived:a beforeFirst:b]+) should pass if the
reference was not received (because 'a' was *not* received before the first
'b', there not being a first 'b'), so we are (currently) forced to make the
positive case the opposite. If this proves to be inconvenient in practice,
this decision can be reconsidered, perhaps by making an addition to the
framework to allow matchers to be aware of their verification context. For
now, for positive tests, it's prudent to first verify that the reference
method has been received by the subject before using this matcher.

Some combinations may seem of limited use, such as "beforeLast" (which does
not fail if the expected message also appears /after/ the reference message),
but might be more useful in their negative ("shouldNot") form, where the
matcher verifies that some message was *not* received in some order. For
example, turning "beforeLast" around, we can test that some message comes
*only after* another, if it was received at all. You may want to combine the
positive and negative forms to verify a strict ordering of messages.

Currently, the matcher can only compare the order of messages sent to a
single instance, not messages sent to two different instances. This would
require some higher-level cooperation between test doubles, which is not
currently in place.

*/
@interface KWHaveReceivedInOrderMatcher : KWMatcher

#pragma mark - Configuring Matchers

- (void)haveReceived:(SEL)aSelector beforeFirst:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector beforeLast:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector afterFirst:(SEL)anotherSelector;
- (void)haveReceived:(SEL)aSelector afterLast:(SEL)anotherSelector;

- (void)haveReceivedAnyMessagesBeforeFirst:(SEL)selector;
- (void)haveReceivedAnyMessagesAfterLast:(SEL)selector;

@end
