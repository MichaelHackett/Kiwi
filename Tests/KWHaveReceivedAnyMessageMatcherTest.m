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

@interface KWHaveReceivedAnyMessageMatcherStringsTest : SenTestCase
@end
@implementation KWHaveReceivedAnyMessageMatcherStringsTest

- (void)testItShouldHaveTheRightMatcherStrings {
    id matcherStrings = [KWHaveReceivedAnyMessageMatcher matcherStrings];
    id expectedStrings = @[
        @"haveReceivedAnyMessages",
        @"haveReceivedSomeMessage"
    ];

    STAssertEqualObjects([matcherStrings sortedArrayUsingSelector:@selector(compare:)],
                         [expectedStrings sortedArrayUsingSelector:@selector(compare:)],
                         @"Expected specific matcher strings.");
}

@end


@interface KWHaveReceivedAnyMessageMatcherTest : SenTestCase
@property (strong, nonatomic) Cruiser *subject;
@property (strong, nonatomic) KWHaveReceivedAnyMessageMatcher *matcher;
@end

@implementation KWHaveReceivedAnyMessageMatcherTest

- (void)setUp {
    self.subject = [KWSpy spyForClass:[Cruiser class]];
    self.matcher = [KWHaveReceivedAnyMessageMatcher matcherWithSubject:self.subject];
}

- (void)tearDown {
    self.subject = nil;
    self.matcher = nil;
}


#pragma mark - Matching

- (void)testItShouldMatchReceivedMessages {
    [self.subject raiseShields];

    [self.matcher haveReceivedAnyMessages];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldMatchAnyNumberOfReceivedMessages {
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceivedAnyMessages];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testItShouldNotMatchIfNoMessagesReceived {
    [self.matcher haveReceivedAnyMessages];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testItShouldIncludeNamesOfMessagesInFailureMessage {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    NSString *failureMessage = [self.matcher failureMessageForShouldNot];
    STAssertTrue([failureMessage containsString:@"raiseShields"] &&
                 [failureMessage containsString:@"engageHyperdrive"],
                 @"Expected failure message to include names of messages sent.");
}

- (void)testSomeMessageFormShouldBeAliasForAnyMessageForm {
    KWHaveReceivedAnyMessageMatcher *altMatcher =
        [KWHaveReceivedAnyMessageMatcher matcherWithSubject:self.subject];
    [altMatcher haveReceivedSomeMessage];
    STAssertEqualObjects(self.matcher, altMatcher,
                         @"Expected 'haveReceivedSomeMessage' matcher to be identical to 'haveReceivedAnyMessages' matcher");
}

@end


@interface KWHaveReceivedAnyMessageMatcherSubjectTypeTest : SenTestCase
@end
@implementation KWHaveReceivedAnyMessageMatcherSubjectTypeTest

- (void)testItShouldRequireSubjectToBeTestSpy {
    Cruiser *subject = [Cruiser cruiser];
    KWHaveReceivedAnyMessageMatcher *matcher =
        [KWHaveReceivedAnyMessageMatcher matcherWithSubject:subject];

    [matcher haveReceivedAnyMessages];
    STAssertThrowsSpecificNamed([matcher evaluate],
                                NSException,
                                @"KWMatcherException",
                                @"Expected exception because subject is not a KWSpy.");
}

@end

#endif // #if KW_TESTS_ENABLED
