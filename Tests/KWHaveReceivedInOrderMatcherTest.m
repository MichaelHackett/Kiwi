//
//  KWHaveReceivedInOrderMatcherTest.m
//  Kiwi
//
//  Created by Michael on 2013-09-03.
//  Copyright (c) 2013 Allen Ding. All rights reserved.
//

#import "Kiwi.h"
#import "KiwiTestConfiguration.h"
#import "TestClasses.h"
#import "NSString+KWSimpleContainmentTestAdditions.h"

#if KW_TESTS_ENABLED

@interface KWHaveReceivedInOrderMatcherStringsTest : SenTestCase
@end

@implementation KWHaveReceivedInOrderMatcherStringsTest

- (void)testItShouldHaveTheRightMatcherStrings {
    id matcherStrings = [KWHaveReceivedInOrderMatcher matcherStrings];
    id expectedStrings = @[
        @"haveReceived:before:",
        @"haveReceived:afterFirst:",
        @"haveReceived:afterLast:"
    ];

    STAssertEqualObjects([matcherStrings sortedArrayUsingSelector:@selector(compare:)],
                         [expectedStrings sortedArrayUsingSelector:@selector(compare:)],
                         @"Expected specific matcher strings.");
}

@end


@interface KWHaveReceivedInOrderMatcherTest : SenTestCase
@property (strong, nonatomic) Cruiser *subject;
@property (strong, nonatomic) KWHaveReceivedInOrderMatcher *matcher;
@end

@implementation KWHaveReceivedInOrderMatcherTest

- (void)setUp {
    self.subject = [KWSpy spyForClass:[Cruiser class]];
    self.matcher = [KWHaveReceivedInOrderMatcher matcherWithSubject:self.subject];
}

- (void)tearDown {
    self.subject = nil;
    self.matcher = nil;
}



#pragma mark - haveReceived:before: tests

- (void)testBeforeMatcherShouldMatchIfMessagesReceivedInSpecifiedOrder {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testBeforeMatcherShouldNotMatchIfReferenceMessageReceivedBeforeMatchMessage {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testBeforeMatcherShouldMatchIfOnlyMatchMessageReceived {
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testBeforeMatcherShouldNotMatchIfOnlyReferenceMessageReceived {
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testBeforeMatcherShouldMatchIfMatchMessageReceivedSeveralTimesBeforeReference {
    [self.subject raiseShields];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testBeforeMatcherShouldMatchIfMatchMessageReceivedBeforeAndAfterReference {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testBeforeMatcherShouldNotMatchIfMatchMessageReceivedBetweenTwoReferenceMessages {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) before:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}



#pragma mark - haveReceived:afterFirst: tests

- (void)testAfterFirstMatcherShouldMatchIfMatchMessageReceivedAfterReferenceMessage {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterFirstMatcherShouldNotMatchIfMatchMessageReceivedBeforeFirstReferenceMessage {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testAfterFirstMatcherShouldMatchIfOnlyMatchMessageReceived {
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterFirstMatcherShouldNotMatchIfOnlyReferenceMessageReceived {
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testAfterFirstMatcherShouldMatchIfMatchMessageReceivedSeveralTimesAfterReference {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterFirstMatcherShouldMatchIfMatchMessageReceivedBetweenTwoReferenceMessages {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterFirstMatcherShouldNotMatchIfMatchMessageReceivedBeforeAndAfterReferenceMessage {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterFirst:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}



#pragma mark - haveReceived:afterFirst: tests

- (void)testAfterLastMatcherShouldMatchIfMatchMessageReceivedAfterReferenceMessage {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterLastMatcherShouldNotMatchIfMatchMessageReceivedBeforeFirstReferenceMessage {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testAfterLastMatcherShouldMatchIfOnlyMatchMessageReceived {
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterLastMatcherShouldNotMatchIfOnlyReferenceMessageReceived {
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testAfterLastMatcherShouldMatchIfMatchMessageReceivedSeveralTimesAfterReference {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass.");
}

- (void)testAfterLastMatcherShouldNotMatchIfMatchMessageReceivedBetweenTwoReferenceMessages {
    [self.subject engageHyperdrive];
    [self.subject raiseShields];
    [self.subject engageHyperdrive];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

- (void)testAfterLastMatcherShouldNotMatchIfMatchMessageReceivedBeforeAndAfterReferenceMessage {
    [self.subject raiseShields];
    [self.subject engageHyperdrive];
    [self.subject raiseShields];

    [self.matcher haveReceived:@selector(raiseShields) afterLast:@selector(engageHyperdrive)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to report failure.");
}

@end



#pragma mark - Textual output

// NOTE:
// The Xcode editor ignores subsequent failures of tests with the same name
// and failure message, reporting only the first such failure. Where the
// test is verifying something related to one of the parameterized elements,
// it's best to put something unique to each configured test case into the
// failure message. (If the failure is the same for all cases, it's probably
// right that Xcode merges the failures, since it's likely that a single fix
// will correct them all, so keep the message the same in that case.)

@interface KWHaveReceivedInOrderMatcherMessagesTest : SenTestCase

// Test parameters
@property (nonatomic, assign, readonly) SEL matcherSelector;
@property (nonatomic, assign) SEL matcherExpectedSelector;
@property (nonatomic, assign) SEL matcherReferenceSelector;
@property (nonatomic, copy, readonly) NSString *expectedOrderMessage;

// Subject of tests
@property (nonatomic, copy) NSString* failureMessage;
@property (nonatomic, copy) NSString* matcherDescription;

@end

@implementation KWHaveReceivedInOrderMatcherMessagesTest

+ (id)defaultTestSuite {
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];
    [testSuite addTest:
     [self testCaseWithMatcherSelector:@selector(haveReceived:before:)
                  expectedOrderMessage:@"before"]];
    [testSuite addTest:
     [self testCaseWithMatcherSelector:@selector(haveReceived:afterFirst:)
                  expectedOrderMessage:@"after first"]];
    [testSuite addTest:
     [self testCaseWithMatcherSelector:@selector(haveReceived:afterLast:)
                  expectedOrderMessage:@"after last"]];

    return [testSuite autorelease];
}

+ (SenTestSuite*)testCaseWithMatcherSelector:(SEL)aMatcherSelector
                        expectedOrderMessage:(NSString *)anExpectedOrderMessage
{
    NSString *testSuiteName = [NSString stringWithFormat:@"matcher: %@",
                               NSStringFromSelector(aMatcherSelector)];
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:testSuiteName];

    // Scan test class for test methods; customize with test parameters and add
    // to test suite.
    [[self testInvocations] enumerateObjectsUsingBlock:
        ^(id testInvocation, NSUInteger index, BOOL *stop) {
            [testSuite addTest:[[[self alloc] initWithInvocation:testInvocation
                                                 matcherSelector:aMatcherSelector
                                         matcherExpectedSelector:@selector(raiseShields)
                                        matcherReferenceSelector:@selector(engageHyperdrive)
                                            expectedOrderMessage:anExpectedOrderMessage]
                                autorelease]];
        }
    ];

    return testSuite;
}

- (id)initWithInvocation:(NSInvocation *)anInvocation
         matcherSelector:(SEL)aMatcherSelector
 matcherExpectedSelector:(SEL)aMatcherExpectedSelector
matcherReferenceSelector:(SEL)aMatcherReferenceSelector
    expectedOrderMessage:(NSString *)anExpectedOrderMessage
{
    self = [super initWithInvocation:anInvocation];
    if (self) {
        _matcherSelector = aMatcherSelector;
        _matcherExpectedSelector = aMatcherExpectedSelector;
        _matcherReferenceSelector = aMatcherReferenceSelector;
        _expectedOrderMessage = [anExpectedOrderMessage copy];
    }
    return self;
}

- (void)dealloc {
    [_expectedOrderMessage release];
    [super dealloc];
}

- (void)setUp {
    KWSpy* subject = [KWSpy spyForClass:[Cruiser class]];
    KWMatcher* matcher = [KWHaveReceivedInOrderMatcher matcherWithSubject:subject];

    // Execute the particular matcher method selected for the test
    IMP matcherMethod = [matcher methodForSelector:self.matcherSelector];
    ((void (*)(id, SEL, SEL, SEL))matcherMethod)(matcher,
                                                 self.matcherSelector,
                                                 self.matcherExpectedSelector,
                                                 self.matcherReferenceSelector);

    // Capture the failure message and matcher description for the tests.
    self.failureMessage = [matcher failureMessageForShould];
    self.matcherDescription = [matcher description];
}

- (void)tearDown {
    self.failureMessage = nil;
    self.matcherDescription = nil;
}

// Extract the text between the two selector strings (if found in the message).
- (NSString*)stringBetweenMethodSelectorsInString:(NSString *)aString {
    NSRange expectedSelectorRange =
        [aString rangeOfString:NSStringFromSelector(self.matcherExpectedSelector)];
    STAssertTrue(expectedSelectorRange.location != NSNotFound,
                 @"Message '%@' does not include expected method name; cannot complete test.",
                 aString);

    NSRange referenceSelectorRange =
        [aString rangeOfString:NSStringFromSelector(self.matcherReferenceSelector)];
    STAssertTrue(referenceSelectorRange.location != NSNotFound,
                 @"Message '%@' does not include reference method name; cannot complete test.",
                 aString);

    NSUInteger rangeStart = NSMaxRange(expectedSelectorRange);
    NSUInteger rangeEnd = referenceSelectorRange.location;
    STAssertTrue(rangeStart < rangeEnd,
                 @"Method names appear in wrong order in message '%@'; cannot complete test.",
                 aString);

    NSRange betweenSelectorsRange = NSMakeRange(rangeStart, rangeEnd - rangeStart);
    return [aString substringWithRange:betweenSelectorsRange];
}


- (void)testFailureMessageShouldIncludeNameOfExpectedMethod {
    NSString* expectedSelectorString = NSStringFromSelector(self.matcherExpectedSelector);
    STAssertTrue([self.failureMessage containsString:expectedSelectorString],
                 @"Failure message, '%@', does not include expected method name, '%@'.",
                 self.failureMessage,
                 expectedSelectorString);
}

- (void)testFailureMessageShouldIncludeNameOfReferenceMethod {
    NSString* referenceSelectorString = NSStringFromSelector(self.matcherReferenceSelector);
    STAssertTrue([self.failureMessage containsString:referenceSelectorString],
                 @"Failure message, '%@', does not include reference method name, '%@'.",
                 self.failureMessage,
                 referenceSelectorString);
}

- (void)testFailureMessageShouldIncludeExpectedOrderingOfMessages {
    // Extract the text between the two selector strings (if found in the message).
    NSString* betweenSelectorsString =
        [self stringBetweenMethodSelectorsInString:self.failureMessage];

    // The remaining text should equal the ordering message, specific to the
    // selected matcher, padded with a single space on either side.
    NSString* expectedOrderString = [NSString stringWithFormat:@" %@ ", self.expectedOrderMessage];
    STAssertEqualObjects(betweenSelectorsString, expectedOrderString,
                         @"Failure message, '%@', does not include order message,"
                          " '%@' between the selector names.",
                         self.failureMessage,
                         self.expectedOrderMessage);
}

// TODO: verify failure message (", but ...")

- (void)testDescriptionShouldIncludeNameOfExpectedMethod {
    NSString* expectedSelectorString = NSStringFromSelector(self.matcherExpectedSelector);
    STAssertTrue([self.matcherDescription containsString:expectedSelectorString],
                 @"Matcher description, '%@', does not include expected method name, '%@'.",
                 self.matcherDescription,
                 expectedSelectorString);
}

- (void)testDescriptionShouldIncludeNameOfReferenceMethod {
    NSString* referenceSelectorString = NSStringFromSelector(self.matcherReferenceSelector);
    STAssertTrue([self.matcherDescription containsString:referenceSelectorString],
                 @"Matcher description, '%@', does not include reference method name, '%@'.",
                 self.matcherDescription,
                 referenceSelectorString);
}

- (void)testDescriptionShouldIncludeExpectedOrderingOfMessages {
    // Extract the text between the two selector strings (if found in the message).
    NSString* betweenSelectorsString =
        [self stringBetweenMethodSelectorsInString:self.matcherDescription];

    // The remaining text should equal the ordering message, specific to the
    // selected matcher, padded with a single space on either side.
    NSString* expectedOrderString = [NSString stringWithFormat:@" %@ ", self.expectedOrderMessage];
    STAssertEqualObjects(betweenSelectorsString, expectedOrderString,
                         @"Matcher description, '%@', does not include order message,"
                         " '%@' between the selector names.",
                         self.matcherDescription,
                         self.expectedOrderMessage);
}

@end

#endif // #if KW_TESTS_ENABLED
