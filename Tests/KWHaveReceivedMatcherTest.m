//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "Kiwi.h"
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
        @"haveReceived:",
        @"haveReceived:withArguments:"
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
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate],
                 @"Expected message was sent to subject.");
}

// TODO: Test with multi-arg methods, rather than single-arg.

- (void)testItShouldMatchMessageWithMatchingArguments {
    [self.subject fighterWithCallsign:@"Viper 1"];

//    [self.matcher haveReceivedMessage:[messageTo(Cruiser) fighterWithCallsign:@"Viper 1"]];
//    [[self.matcher haveReceived] fighterWithCallsign:@"Viper 1"];
    [self.matcher haveReceived:@selector(fighterWithCallsign:)
                 withArguments:@[@"Viper 1"]];
    STAssertTrue([self.matcher evaluate],
                 @"Expected message was sent to subject with expected arguments");
}

- (void)testItShouldNotMatchMessageWithDifferentArguments {
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(fighterWithCallsign:)
                 withArguments:@[@"Viper 2"]];
    STAssertFalse([self.matcher evaluate],
                  @"Expected message was not sent to subject with expected arguments");
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

// capture multiple invocations of same method
// -- same arguments and differing arguments

// report number of invocations matching specification

#endif // #if KW_TESTS_ENABLED
