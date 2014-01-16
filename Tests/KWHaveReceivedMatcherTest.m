//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "Kiwi.h"
#import "KiwiTestConfiguration.h"
#import "TestClasses.h"
#import "NSString+KWSimpleContainmentTestAdditions.h"

#if KW_TESTS_ENABLED

@interface KWHaveReceivedMatcherStringsTest : SenTestCase
@end
@implementation KWHaveReceivedMatcherStringsTest

- (void)testItShouldHaveTheRightMatcherStrings {
    id matcherStrings = [KWHaveReceivedMatcher matcherStrings];
    id expectedStrings = @[
        @"haveReceived:",
        @"haveReceived:withCount:",
        @"haveReceived:withCountAtLeast:",
        @"haveReceived:withCountAtMost:",
        @"haveReceived:withArguments:",
        @"haveReceived:withCount:arguments:",
        @"haveReceived:withCountAtLeast:arguments:",
        @"haveReceived:withCountAtMost:arguments:"
    ];

    STAssertEqualObjects([matcherStrings sortedArrayUsingSelector:@selector(compare:)],
                         [expectedStrings sortedArrayUsingSelector:@selector(compare:)],
                         @"Expected specific matcher strings.");
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


#pragma mark - Matching by message selector only

- (void)testItShouldMatchReceivedMessages {
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchAnyNumberOfReceivedMessages {
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchNonReceivedMessages {
    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldNotMatchDifferentMessages {
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertFalse([self.matcher evaluate], @"Expected message to report failure.");
}

- (void)testItShouldMatchMessageReceivedAmongstOtherMessages {
    [self.subject computeParsecs];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];  // message that we're interested in
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchWhenReceivedMessageCountEqualsExactCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(raiseShields) withCount:3];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchWhenReceivedMessageCountIsLessThanExactCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) withCount:3];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldNotMatchWhenReceivedMessageCountIsGreaterThanExactCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) withCount:3];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldMatchWhenReceivedMessageCountEqualsMinimumCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(raiseShields) withCountAtLeast:3];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchWhenReceivedMessageCountIsLessThanMinimumCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) withCountAtLeast:3];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldMatchWhenReceivedMessageCountIsGreaterThanMinimumCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) withCountAtLeast:3];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchWhenReceivedMessageCountEqualsMaximumCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(raiseShields) withCountAtMost:3];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchWhenReceivedMessageCountIsLessThanMaximumCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) withCountAtMost:3];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchWhenReceivedMessageCountIsGreaterThanMaximumCount {
    [self.subject computeParsecs];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) withCountAtMost:3];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}


#pragma mark - Matching selector and arguments

- (void)testItShouldMatchMessageWithMatchingArguments {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:99];

//    [[self.matcher haveReceived] sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:99];
    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
                 withArguments:@[@"SOS", @"Viper 1", theValue(99)]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchAnyNumberOfReceivedMessagesWithMatchingArguments {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:5];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"XYZ" repeatCount:5];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
                 withArguments:@[@"SOS", any(), theValue(5)]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchMessageWithDifferentArguments {
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(fighterWithCallsign:)
                 withArguments:@[@"Viper 2"]];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testMatcherWithArgumentsShouldRequireEnoughArgumentMatchersForMessage {
    // specify matcher with too few argument matchers
    STAssertThrowsSpecificNamed(
        [self.matcher haveReceived:@selector(performSelectorInBackground:withObject:)
                     withArguments:@[[NSValue valueWithPointer:@selector(description)]]],
        NSException,
        NSInvalidArgumentException,
        @"Expected exception because too few argument matchers passed to haveReceived:withArguments:"
    );
}

- (void)testItShouldMatchWhenCountOfReceivedMessagesMatchingArgumentsEqualsExactCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 2" repeatCount:13];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:3];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
                     withCount:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchWhenCountOfReceivedMessagesMatchingArgumentsIsLessThanExactCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 2" repeatCount:13];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
                     withCount:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldNotMatchWhenCountOfReceivedMessagesMatchingArgumentsIsGreaterThanExactCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:5];
    [self.subject fighterWithCallsign:@"Viper 1"];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:92];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
                     withCount:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldMatchWhenCountOfReceivedMessagesMatchingArgumentsEqualsMinimumCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 2" repeatCount:13];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:3];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
              withCountAtLeast:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchWhenCountOfReceivedMessagesMatchingArgumentsIsLessThanMinimumCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 2" repeatCount:13];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
              withCountAtLeast:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldMatchWhenCountOfReceivedMessagesMatchingArgumentsIsGreaterThanMinimumCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:5];
    [self.subject fighterWithCallsign:@"Viper 1"];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:92];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
              withCountAtLeast:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchWhenCountOfReceivedMessagesMatchingArgumentsEqualsMaximumCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 2" repeatCount:13];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:3];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
               withCountAtMost:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchWhenCountOfReceivedMessagesMatchingArgumentsIsLessThanMaximumCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 2" repeatCount:13];
    [self.subject fighterWithCallsign:@"Viper 1"];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
               withCountAtMost:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchWhenCountOfReceivedMessagesMatchingArgumentsIsGreaterThanMaximumCount {
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:10];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:11];
    [self.subject raiseShields];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:5];
    [self.subject fighterWithCallsign:@"Viper 1"];
    [self.subject sendMessage:@"SOS" toShipWithCallSign:@"Viper 1" repeatCount:92];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(sendMessage:toShipWithCallSign:repeatCount:)
               withCountAtMost:3
                     arguments:@[@"SOS", @"Viper 1", any()]];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}


#pragma mark - Textual output

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

- (void)testItCannotMatchASubjectThatIsNotATestSpy {
    STAssertFalse([KWHaveReceivedMatcher canMatchSubject:[Cruiser cruiser]],
                  @"Expected canMatchSubject: to return NO");
}

- (void)testItCanMatchASubjectThatIsATestSpy {
    id spy = [KWSpy spyForClass:[Cruiser class]];
    STAssertTrue([KWHaveReceivedMatcher canMatchSubject:spy],
                  @"Expected canMatchSubject: to return YES");
}

// Probably an unnecessary specification, if there is no way for the matcher
// to be evaluated without the verifier first checking with `+canMatchSubject:`.
// But I can't figure out a suitable test to verify this, so I'll leave this
// for now.
- (void)testMatcherShouldFailIfSubjectIsNotATestSpy {
    Cruiser *subject = [Cruiser cruiser];

//    [[KWExampleSuiteBuilder sharedExampleSuiteBuilder] buildExampleSuite:^{
//        describe(@"haveReceived matcher", ^{
//            it(@"is not supported for non-spy objects", ^{
//                [[subject should] haveReceived:@selector(raiseShields)];
//            });
//        });
//    }];

    KWHaveReceivedMatcher *matcher =
        [KWHaveReceivedMatcher matcherWithSubject:subject];
    [matcher haveReceived:@selector(raiseShields)];
    STAssertThrowsSpecificNamed([matcher evaluate],
                                NSException,
                                @"KWMatcherException",
                                @"Expected exception because subject is not a KWSpy.");
}

@end

#endif // #if KW_TESTS_ENABLED
