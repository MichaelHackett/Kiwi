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

@interface NSString (KWStreamlinedContainmentTestAdditions)
- (BOOL)containsString:(NSString *)string;
@end
@implementation NSString (KWStreamlinedContainmentTestAdditions)

- (BOOL)containsString:(NSString *)string {
    NSRange matchRange = [self rangeOfString:string];
    return matchRange.location != NSNotFound;
}

@end


@interface KWHaveReceivedMatcherStringsTest : SenTestCase
@end
@implementation KWHaveReceivedMatcherStringsTest

- (void)testItShouldHaveTheRightMatcherStrings {
    id matcherStrings = [KWHaveReceivedMatcher matcherStrings];
    id expectedStrings = @[
        @"haveReceived:" //,
    //                         @"receive:withCount:",
    //                         @"receive:withCountAtLeast:",
    //                         @"receive:withCountAtMost:",
    //                         @"receiveMessagePattern:countType:count:",
    ];

    STAssertEqualObjects([matcherStrings sortedArrayUsingSelector:@selector(compare:)],
                         [expectedStrings sortedArrayUsingSelector:@selector(compare:)],
                         @"expected specific matcher strings");
}

@end


@interface KWHaveReceivedMatcherTest : SenTestCase
@property (strong, nonatomic) Cruiser *subject;
@property (strong, nonatomic) KWHaveReceivedMatcher *matcher;
@end

@implementation KWHaveReceivedMatcherTest

- (void)setUp {
    self.subject = [KWSpy spyForClass:[Cruiser class]];
    self.matcher = [KWHaveReceivedMatcher matcherWithSubject:self.subject];
}

- (void)tearDown {
//  KWClearStubsAndSpies();
    self.subject = nil;
    self.matcher = nil;
}

- (void)testItShouldMatchReceivedMessages {
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate],
                 @"Expected message was sent to subject.");
}

- (void)testItShouldNotMatchNonReceivedMessages {
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertFalse([self.matcher evaluate],
                  @"Expected message was not sent to subject.");
}

- (void)testItShouldMatchMessageReceivedAmongstOtherMessages {
    [self.subject computeParsecs];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];  // message that we're interested in
    [self.subject fighterWithCallsign:@"A535"];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate],
                 @"Expected message was sent to subject.");
}

- (void)testFailureMessageShouldIncludeNameOfMethodToMatch {
    SEL expectedSelector = @selector(raiseShields);
    [self.matcher haveReceived:expectedSelector];

    STAssertTrue([[self.matcher failureMessageForShould]
                  containsString:NSStringFromSelector(expectedSelector)],
                 @"Failure message does not include expected method name.");
}

- (void)testDescriptionShouldIncludeNameOfMethodToMatch {
    SEL expectedSelector = @selector(raiseShields);
    [self.matcher haveReceived:expectedSelector];

    NSString *matchString = [NSString stringWithFormat:@"received message %@",
                             NSStringFromSelector(expectedSelector)];
    STAssertTrue([[self.matcher description] containsString:matchString],
                 @"Object description does not include expected text and/or method name.");
}

@end


@interface KWHaveReceivedMatcherSubjectTypeTest : SenTestCase
@end
@implementation KWHaveReceivedMatcherSubjectTypeTest

- (void)testItShouldRequireSubjectToBeTestSpy {
    Cruiser *subject = [Cruiser cruiser];
    KWHaveReceivedMatcher *matcher =
        [KWHaveReceivedMatcher matcherWithSubject:subject];

    [matcher haveReceived:@selector(raiseShields)];
    STAssertThrowsSpecificNamed([matcher evaluate],
                                NSException,
                                @"KWMatcherException",
                                @"expected exception because subject is not a KWSpy");
}

@end

// capture multiple invocations of same method -- test by invoking method multiple times with different arguments
// capture argument values

// shouldHaveReceived will require:
// report match based on method name and arguments
// report number of invocations matching specification

#endif // #if KW_TESTS_ENABLED
