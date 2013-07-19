//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "Kiwi.h"
#import "KWHaveReceivedMatcher.h" // TODO: move this to Kiwi.h
#import "KWSpy.h"
#import "KiwiTestConfiguration.h"
#import "TestClasses.h"
//#import "KWIntercept.h"

#if KW_TESTS_ENABLED

@interface KWHaveReceivedMatcherTest : SenTestCase

@end

@implementation KWHaveReceivedMatcherTest

//- (void)tearDown {
//  KWClearStubsAndSpies();
//}
- (void)testItShouldHaveTheRightMatcherStrings {
    id matcherStrings = [KWHaveReceivedMatcher matcherStrings];
    id expectedStrings = @[@"haveReceived:"];
//                         @"receive:withCount:",
//                         @"receive:withCountAtLeast:",
//                         @"receive:withCountAtMost:",
//                         @"receive:andReturn:",
//                         @"receive:andReturn:withCount:",
//                         @"receive:andReturn:withCountAtLeast:",
//                         @"receive:andReturn:withCountAtMost:",
//                         @"receiveMessagePattern:countType:count:",
//                         @"receiveMessagePattern:andReturn:countType:count:"];
    STAssertEqualObjects([matcherStrings sortedArrayUsingSelector:@selector(compare:)],
                         [expectedStrings sortedArrayUsingSelector:@selector(compare:)],
                         @"expected specific matcher strings");
}

// test: should only accept subjects of type KWMock, or which meet some protocol

- (void)testItShouldMatchReceivedMessagesForReceive {
    id subject = [KWSpy spyForClass:[Cruiser class]];
    id matcher = [KWHaveReceivedMatcher matcherWithSubject:subject];
    [subject raiseShields];
    [matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([matcher evaluate], @"expected message to have been received");
}

- (void)testItShouldNotMatchNonReceivedMessagesForReceive {
    id subject = [KWSpy spyForClass:[Cruiser class]];
    id matcher = [KWHaveReceivedMatcher matcherWithSubject:subject];
    [subject engageHyperdrive];
    [matcher haveReceived:@selector(raiseShields)];
    STAssertFalse([matcher evaluate], @"expected message not to have been received");
}

@end

// capture method invocations (multiple different methods)
// capture multiple invocations of same method
// capture argument values

// shouldHaveReceived will require:
// report whether invocation was received based just on message name
// report match based on method name and arguments
// report number of invocations matching specification

// should not allow subjects that are not KWSpys

#endif // #if KW_TESTS_ENABLED
