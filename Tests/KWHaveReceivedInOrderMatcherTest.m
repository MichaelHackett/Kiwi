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
        @"haveReceived:beforeFirst:",
        @"haveReceived:afterFirst:",
        @"haveReceived:afterLast:"
    ];

    STAssertEqualObjects([matcherStrings sortedArrayUsingSelector:@selector(compare:)],
                         [expectedStrings sortedArrayUsingSelector:@selector(compare:)],
                         @"Expected specific matcher strings.");
}

@end



#pragma mark - Matcher logic tests

@interface KWHaveReceivedInOrderMatcherTest : SenTestCase

// Test parameters
@property (nonatomic, assign, readonly) SEL matcherSelector;
@property (nonatomic, assign, readonly) SEL testExerciseSelector;
@property (nonatomic, assign) SEL matcherExpectedSelector;
@property (nonatomic, assign) SEL matcherReferenceSelector;
@property (nonatomic, assign) BOOL matcherShouldPass;
//@property (nonatomic, copy, readonly) NSString *expectedOrderMessage;

// Subject of tests
@property (nonatomic, strong) KWHaveReceivedInOrderMatcher* matcher;

// Test spy that is the subject of the matcher.
@property (nonatomic, strong) Carrier* matcherSubject;  // shorten name to clean up test exercising blocks?

@end

@implementation KWHaveReceivedInOrderMatcherTest

#pragma mark - Parameterized test case initialization

- (id)initWithInvocation:(NSInvocation *)anInvocation
         matcherSelector:(SEL)aMatcherSelector
    testExerciseSelector:(SEL)aTestExerciseSelector
 matcherExpectedSelector:(SEL)aMatcherExpectedSelector
matcherReferenceSelector:(SEL)aMatcherReferenceSelector
       matcherShouldPass:(BOOL)theMatcherShouldPass
{
    self = [super initWithInvocation:anInvocation];
    if (self) {
        _matcherSelector = aMatcherSelector;
        _testExerciseSelector = aTestExerciseSelector;
        _matcherExpectedSelector = aMatcherExpectedSelector;
        _matcherReferenceSelector = aMatcherReferenceSelector;
        _matcherShouldPass = theMatcherShouldPass;
    }
    return self;
}


#pragma mark - Test suite definition

+ (id)defaultTestSuite {
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];

    // WARNING: If you get any of these names wrong, your test suite will
    // abort (because of the exception we throw if a matching method cannot
    // be found at runtime), but Xcode LIES and says your tests ran without
    // issues. (So be sure to check the test log the first time after making
    // changes here, and look in the debugger console to find out which is
    // the offending selector name.)
    //
    // Because of this issue, and to support auto-completion in the editor,
    // using actual selectors instead of strings might actually be preferable,
    // despite the extra noise introduced by adding "@selector(...)" to each
    // string. (We'd also have to switch to vararg methods, because selectors
    // (SEL) can't be put into NSArrays.)
    //
    // Alternative idea: Could make the case strings plain text and convert
    // to selector by removing spaces and camel-casing, e.g., "only expected
    // message received" -> "caseOnlyExpectedMessageReceived".

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:beforeFirst:"
         casesPassingMatcher:@[
             @"caseExpectedMessageReceivedOnceBeforeReferenceMessage",
             @"caseExpectedMessageReceivedMultipleTimesBeforeReferenceMessage",
             @"caseExpectedMessageReceivedBeforeAndAfterReferenceMessage",
             @"caseOnlyExpectedMessageReceived"
         ]
         casesFailingMatcher:@[
             @"caseExpectedMessageReceivedOnceAfterReferenceMessage",
             @"caseExpectedMessageReceivedMultipleTimesAfterReferenceMessage",
             @"caseExpectedMessageReceivedOnceBetweenTwoReferenceMessages",
             @"caseOnlyReferenceMessageReceived"
         ]
      ]];

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:afterFirst:"
         casesPassingMatcher:@[
             @"caseExpectedMessageReceivedOnceAfterReferenceMessage",
             @"caseExpectedMessageReceivedMultipleTimesAfterReferenceMessage",
             @"caseExpectedMessageReceivedOnceBetweenTwoReferenceMessages",
             @"caseExpectedMessageReceivedBeforeAndAfterReferenceMessage",
             @"caseOnlyExpectedMessageReceived"
         ]
         casesFailingMatcher:@[
             @"caseExpectedMessageReceivedOnceBeforeReferenceMessage",
             @"caseExpectedMessageReceivedMultipleTimesBeforeReferenceMessage",
             @"caseOnlyReferenceMessageReceived"
         ]
      ]];

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:afterLast:"
         casesPassingMatcher:@[
             @"caseExpectedMessageReceivedOnceAfterReferenceMessage",
             @"caseExpectedMessageReceivedMultipleTimesAfterReferenceMessage",
             @"caseExpectedMessageReceivedBeforeAndAfterReferenceMessage",
             @"caseOnlyExpectedMessageReceived"
         ]
         casesFailingMatcher:@[
             @"caseExpectedMessageReceivedOnceBeforeReferenceMessage",
             @"caseExpectedMessageReceivedMultipleTimesBeforeReferenceMessage",
             @"caseExpectedMessageReceivedOnceBetweenTwoReferenceMessages",
             @"caseOnlyReferenceMessageReceived"
         ]
      ]];

    return [testSuite autorelease];
}

#pragma mark - Test conditions

- (void)caseExpectedMessageReceivedOnceBeforeReferenceMessage {
    [self.matcherSubject raiseShields];
    [self.matcherSubject engageHyperdrive];
}

- (void)caseExpectedMessageReceivedOnceAfterReferenceMessage {
    [self.matcherSubject engageHyperdrive];
    [self.matcherSubject raiseShields];
}

- (void)caseExpectedMessageReceivedMultipleTimesBeforeReferenceMessage {
    [self.matcherSubject raiseShields];
    [self.matcherSubject raiseShields];
    [self.matcherSubject engageHyperdrive];
}

- (void)caseExpectedMessageReceivedMultipleTimesAfterReferenceMessage {
    [self.matcherSubject engageHyperdrive];
    [self.matcherSubject raiseShields];
    [self.matcherSubject raiseShields];
}

- (void)caseExpectedMessageReceivedBeforeAndAfterReferenceMessage {
    [self.matcherSubject raiseShields];
    [self.matcherSubject engageHyperdrive];
    [self.matcherSubject raiseShields];
}

- (void)caseExpectedMessageReceivedOnceBetweenTwoReferenceMessages {
    [self.matcherSubject engageHyperdrive];
    [self.matcherSubject raiseShields];
    [self.matcherSubject engageHyperdrive];
}

- (void)caseOnlyExpectedMessageReceived {
    [self.matcherSubject raiseShields];
}

- (void)caseOnlyReferenceMessageReceived {
    [self.matcherSubject engageHyperdrive];
}



#pragma mark - Test suite creation support

+ (SenTestSuite*)testSuiteForMatcherSelector:(NSString*)aMatcherSelectorString
                         casesPassingMatcher:(NSArray*)selectorStringsForCasesPassingMatcher
                         casesFailingMatcher:(NSArray*)selectorStringsForCasesFailingMatcher
{
    SEL matcherSelector = [self selectorForString:aMatcherSelectorString
                               onInstancesOfClass:[KWHaveReceivedInOrderMatcher class]];
    NSString *testSuiteName = [NSString stringWithFormat:@"matcher %@", aMatcherSelectorString];
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:testSuiteName];

    [self addTestCasesForMatcherSelector:matcherSelector
              usingTestExerciseSelectors:selectorStringsForCasesPassingMatcher
                  whereMatcherShouldPass:YES
                             toTestSuite:testSuite];
    [self addTestCasesForMatcherSelector:matcherSelector
              usingTestExerciseSelectors:selectorStringsForCasesFailingMatcher
                  whereMatcherShouldPass:NO
                             toTestSuite:testSuite];

    return testSuite;
}

+ (void)addTestCasesForMatcherSelector:(SEL)aMatcherSelector
            usingTestExerciseSelectors:(NSArray*)testExerciseSelectors
                whereMatcherShouldPass:(BOOL)matcherShouldPass
                           toTestSuite:(SenTestSuite*)testSuite
{
    // Create a parameterized test case for each of the test exercise cases.
    [testExerciseSelectors enumerateObjectsUsingBlock:
     ^(id selectorString, NSUInteger index, BOOL *stop) {
         SEL testExerciseSelector = [self selectorForString:selectorString
                                         onInstancesOfClass:[self class]];

         [testSuite addTest:[self testCaseForMatcherSelector:aMatcherSelector
                                        testExerciseSelector:testExerciseSelector
                                           matcherShouldPass:matcherShouldPass]];
     }];
}

// This may not need to be a suite; if there is only one test method, could
// change the return type to a SenTestCase and clean up the output a bit.

//+ (SenTestSuite*)testSuiteForMatcherSelector:(SEL)aMatcherSelector
//                        testExerciseSelector:(SEL)aTestExerciseSelector
//                           matcherShouldPass:(BOOL)theMatcherShouldPass
//{
//    NSString *testSuiteName = [NSString stringWithFormat:@"matcher '%@' with test case '%@'",
//                               NSStringFromSelector(aMatcherSelector),
//                               NSStringFromSelector(aTestExerciseSelector)];
//    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:testSuiteName];
//
//    // Scan test class for test methods; customize with test parameters and add
//    // to test suite.
//    [[self testInvocations] enumerateObjectsUsingBlock:
//     ^(id testInvocation, NSUInteger index, BOOL *stop) {
//         [testSuite addTest:[[[self alloc] initWithInvocation:testInvocation
//                                              matcherSelector:aMatcherSelector
//                                         testExerciseSelector:aTestExerciseSelector
//                                      matcherExpectedSelector:@selector(raiseShields)
//                                     matcherReferenceSelector:@selector(engageHyperdrive)
//                                            matcherShouldPass:theMatcherShouldPass]
//                             autorelease]];
//     }];
//
//    return testSuite;
//}

+ (SenTestCase*)testCaseForMatcherSelector:(SEL)aMatcherSelector
                      testExerciseSelector:(SEL)aTestExerciseSelector
                         matcherShouldPass:(BOOL)theMatcherShouldPass
{
    NSInvocation *testInvocation =
        [NSInvocation invocationWithMethodSignature:
         [self instanceMethodSignatureForSelector:@selector(testMatcher)]];
    [testInvocation setSelector:@selector(testMatcher)];

    SenTestCase* testCase =
        [[self alloc] initWithInvocation:testInvocation
                         matcherSelector:aMatcherSelector
                    testExerciseSelector:aTestExerciseSelector
                 matcherExpectedSelector:@selector(raiseShields)
                matcherReferenceSelector:@selector(engageHyperdrive)
                       matcherShouldPass:theMatcherShouldPass];
    return [testCase autorelease];
}

+ (SEL)selectorForString:(NSString*)aSelectorString
      onInstancesOfClass:(Class)aClass
{
    SEL selector = NSSelectorFromString(aSelectorString);
    if (!selector || ![aClass instancesRespondToSelector:selector]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%@ - no such method on %@ class",
                           aSelectorString,
                           NSStringFromClass(aClass)];
    }
    return selector;
}


#pragma mark - Parameterized test case execution

- (void)setUp {
    self.matcherSubject = [KWSpy spyForClass:[Cruiser class]];
    self.matcher = [KWHaveReceivedInOrderMatcher matcherWithSubject:self.matcherSubject];
}

- (void)tearDown {
    self.matcher = nil;
    self.matcherSubject = nil;
}

- (void)testMatcher {
    // Exercise the test spy, as specified for this test case.
    [self performSelector:self.testExerciseSelector];

    // Execute the particular matcher method selected for the test
    IMP matcherMethod = [self.matcher methodForSelector:self.matcherSelector];
    ((void (*)(id, SEL, SEL, SEL))matcherMethod)(self.matcher,
                                                 self.matcherSelector,
                                                 self.matcherExpectedSelector,
                                                 self.matcherReferenceSelector);

    // Compare actual matcher result with expected.
    if ([self.matcher evaluate] != self.matcherShouldPass) {
        STFail(@"Expected matcher %@ to %@ for condition: %@.",
               NSStringFromSelector(self.matcherSelector),
               self.matcherShouldPass ? @"pass" : @"report failure",
               NSStringFromSelector(self.testExerciseSelector));
    }
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
     [self testCaseWithMatcherSelector:@selector(haveReceived:beforeFirst:)
                  expectedOrderMessage:@"before first"]];
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
