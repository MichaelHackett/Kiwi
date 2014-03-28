//
//  KWHaveReceivedInOrderMatcherTest.m
//  Kiwi
//
//  Copyright 2013-4 Michael Hackett. All rights reserved.
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
        @"haveReceived:beforeLast:",
        @"haveReceived:afterFirst:",
        @"haveReceived:afterLast:",
        @"haveReceivedAnyMessagesBeforeFirst:",
        @"haveReceivedAnyMessagesAfterLast:"
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
@property (nonatomic, copy, readonly) NSString* exerciseMessagePattern;
@property (nonatomic, assign) SEL matcherExpectedSelector;
@property (nonatomic, assign) SEL matcherReferenceSelector;
@property (nonatomic, assign) BOOL matcherShouldPass;

// Subject of tests
@property (nonatomic, strong) KWHaveReceivedInOrderMatcher* matcher;

// Test spy that is the subject of the matcher.
@property (nonatomic, strong) Carrier* matcherSubject;

@end

@implementation KWHaveReceivedInOrderMatcherTest

#pragma mark - Parameterized test case initialization

- (id)initWithInvocation:(NSInvocation *)anInvocation
         matcherSelector:(SEL)aMatcherSelector
  exerciseMessagePattern:(NSString *)anExerciseMessagePattern
 matcherExpectedSelector:(SEL)aMatcherExpectedSelector
matcherReferenceSelector:(SEL)aMatcherReferenceSelector
       matcherShouldPass:(BOOL)theMatcherShouldPass
{
    self = [super initWithInvocation:anInvocation];
    if (self) {
        _matcherSelector = aMatcherSelector;
        _exerciseMessagePattern = [anExerciseMessagePattern copy];
        _matcherExpectedSelector = aMatcherExpectedSelector;
        _matcherReferenceSelector = aMatcherReferenceSelector;
        _matcherShouldPass = theMatcherShouldPass;
    }
    return self;
}

- (void)dealloc {
    [_exerciseMessagePattern release];
    [super dealloc];
}



#pragma mark - Test suite definition

// Each of the short strings describing the test cases below (e.g., "ab",
// "abba") represents a pattern of messages to be sent to a test spy that will
// be the subject of the matcher being tested. Each "a" is translated into a
// send of the "expected" message (the first argument to the matcher method);
// each "b" is translated into a send of the "reference" message. (An empty
// string is a valid test that sends no messages to the spy.)
//
// Any adjacent repeated letters (e.g., "aa" or "bb") should behave logically
// as if there was just one of that letter, so we only exhaustively test all
// combinations up to 3 messages (to ensure that repeated messages are handled
// correctly), and then just test the unique cases beyond that.
//
// Note the special cases: If the expected message is never received, the
// matcher always fails; if the expected message is never received, the
// matcher always fails. (The matcher definition is that it passes if the "a"
// message was received AND (at least one instance of the "a" message meets the
// specified relative ordering with respect to the "b" message, IF the "b"
// message was present).)

+ (id)defaultTestSuite {
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:beforeFirst:"
                   casesPassingMatcher:@"ab,aab,aba,abb,abab,ababa"
                   casesFailingMatcher:@",a,aa,aaa,b,ba,bb,baa,bab,bba,bbb,baba"]];

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:beforeLast:"
                   casesPassingMatcher:@"ab,aab,aba,abb,bab,abab,baba,ababa"
                   casesFailingMatcher:@",a,aa,aaa,b,ba,bb,baa,bba,bbb"]];

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:afterFirst:"
                   casesPassingMatcher:@"ba,aba,baa,bab,bba,abab,baba,ababa"
                   casesFailingMatcher:@",a,aa,aaa,b,ab,bb,aab,abb,bbb"]];

    [testSuite addTest:
     [self testSuiteForMatcherSelector:@"haveReceived:afterLast:"
                   casesPassingMatcher:@"ba,aba,baa,bba,baba,ababa"
                   casesFailingMatcher:@",a,aa,aaa,b,ab,bb,aab,abb,bab,bbb,abab"]];

    return [testSuite autorelease];
}



#pragma mark - Test suite creation support

+ (SenTestSuite*)testSuiteForMatcherSelector:(NSString*)aMatcherSelectorString
                         casesPassingMatcher:(NSString*)casesPassingMatcher
                         casesFailingMatcher:(NSString*)casesFailingMatcher
{
    SEL matcherSelector = [self selectorForString:aMatcherSelectorString
                               onInstancesOfClass:[KWHaveReceivedInOrderMatcher class]];
    NSString *testSuiteName = [NSString stringWithFormat:@"matcher %@", aMatcherSelectorString];
    SenTestSuite *testSuite = [[SenTestSuite alloc] initWithName:testSuiteName];

    [self addTestCasesForMatcherSelector:matcherSelector
                  whereMatcherShouldPass:YES
                 forEachMessagePatternIn:casesPassingMatcher
                             toTestSuite:testSuite];
    [self addTestCasesForMatcherSelector:matcherSelector
                  whereMatcherShouldPass:NO
                 forEachMessagePatternIn:casesFailingMatcher
                             toTestSuite:testSuite];

    return testSuite;
}

+ (void)addTestCasesForMatcherSelector:(SEL)aMatcherSelector
                whereMatcherShouldPass:(BOOL)matcherShouldPass
               forEachMessagePatternIn:(NSString*)messagePatternList
                           toTestSuite:(SenTestSuite*)testSuite
{
    // Create a parameterized test case for each of the test exercise cases.
    NSCharacterSet* patternSeparators = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSArray* messagePatterns =
        [messagePatternList componentsSeparatedByCharactersInSet:patternSeparators];
    [messagePatterns enumerateObjectsUsingBlock:
     ^(NSString* messagePattern, NSUInteger index, BOOL *stop) {
         [testSuite addTest:[self testCaseForMatcherSelector:aMatcherSelector
                                 usingExerciseMessagePattern:messagePattern
                                           matcherShouldPass:matcherShouldPass]];
     }];
}

+ (SenTestCase*)testCaseForMatcherSelector:(SEL)aMatcherSelector
               usingExerciseMessagePattern:(NSString*)anExerciseMessagePattern
                         matcherShouldPass:(BOOL)theMatcherShouldPass
{
    NSInvocation *testInvocation =
        [NSInvocation invocationWithMethodSignature:
         [self instanceMethodSignatureForSelector:@selector(testMatcher)]];
    [testInvocation setSelector:@selector(testMatcher)];

    SenTestCase* testCase =
        [[self alloc] initWithInvocation:testInvocation
                         matcherSelector:aMatcherSelector
                  exerciseMessagePattern:anExerciseMessagePattern
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
    self.matcherSubject = [KWSpy spyForClass:[Carrier class]];
    self.matcher = [KWHaveReceivedInOrderMatcher matcherWithSubject:self.matcherSubject];
}

- (void)tearDown {
    self.matcher = nil;
    self.matcherSubject = nil;
}

- (void)testMatcher {
    // Exercise the test spy, as specified for this test case.
    [self exerciseMatcherSubject];

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
               self.exerciseMessagePattern);
    }
}

- (void)exerciseMatcherSubject {
    NSString* messagePattern = self.exerciseMessagePattern;
    NSUInteger patternLength = [messagePattern length];
    for (NSUInteger i = 0; i < patternLength; i++) {
        unichar messageCode = [messagePattern characterAtIndex:i];
        if (messageCode == 'a') {
            [self.matcherSubject performSelector:self.matcherExpectedSelector]; // assumes no-arg method
        }
        else if (messageCode == 'b') {
            [self.matcherSubject performSelector:self.matcherReferenceSelector];
        }
        // else, ignore code
    }
}

@end



#pragma mark - "Any Message" ordered matchers

@interface KWHaveReceivedAnythingBeforeSelectorMatcherTest : SenTestCase

// Subject of tests
@property (nonatomic, strong) KWHaveReceivedInOrderMatcher* matcher;

// Test spy that is the subject of the matcher.
@property (nonatomic, strong) Cruiser* matcherSubject;

@end

@implementation KWHaveReceivedAnythingBeforeSelectorMatcherTest

- (void)setUp {
    self.matcherSubject = [KWSpy spyForClass:[Cruiser class]];
    self.matcher = [KWHaveReceivedInOrderMatcher matcherWithSubject:self.matcherSubject];
}

- (void)tearDown {
    self.matcher = nil;
    self.matcherSubject = nil;
}

- (void)testMatcherPassesIfSomeMessageReceivedBeforeReference {
    // Execise
    [self.matcherSubject fighterWithCallsign:@"Omega"];
    [self.matcherSubject raiseShields];

    // Verification
    [self.matcher haveReceivedAnyMessagesBeforeFirst:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass");
}

- (void)testMatcherFailsIfNoMessageReceivedBeforeReference {
    // Execise
    [self.matcherSubject raiseShields];
    [self.matcherSubject fighterWithCallsign:@"Omega"];

    // Verification
    [self.matcher haveReceivedAnyMessagesBeforeFirst:@selector(raiseShields)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to fail");
}

@end


@interface KWHaveReceivedAnythingAfterSelectorMatcherTest : SenTestCase

// Subject of tests
@property (nonatomic, strong) KWHaveReceivedInOrderMatcher* matcher;

// Test spy that is the subject of the matcher.
@property (nonatomic, strong) Cruiser* matcherSubject;

@end

@implementation KWHaveReceivedAnythingAfterSelectorMatcherTest

- (void)setUp {
    self.matcherSubject = [KWSpy spyForClass:[Cruiser class]];
    self.matcher = [KWHaveReceivedInOrderMatcher matcherWithSubject:self.matcherSubject];
}

- (void)tearDown {
    self.matcher = nil;
    self.matcherSubject = nil;
}

- (void)testMatcherPassesIfSomeMessageReceivedAfterReference {
    // Execise
    [self.matcherSubject raiseShields];
    [self.matcherSubject fighterWithCallsign:@"Omega"];

    // Verification
    [self.matcher haveReceivedAnyMessagesAfterLast:@selector(raiseShields)];
    STAssertTrue([self.matcher evaluate], @"Expected matcher to pass");
}

- (void)testMatcherFailsIfNoMessageReceivedAfterReference {
    // Execise
    [self.matcherSubject fighterWithCallsign:@"Omega"];
    [self.matcherSubject raiseShields];

    // Verification
    [self.matcher haveReceivedAnyMessagesAfterLast:@selector(raiseShields)];
    STAssertFalse([self.matcher evaluate], @"Expected matcher to fail");
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
     [self testCaseWithMatcherSelector:@selector(haveReceived:beforeLast:)
                  expectedOrderMessage:@"before last"]];
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
    KWSpy* subject = [KWSpy spyForClass:[Carrier class]];
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


@interface KWHaveReceivedInOrderMatcherSubjectTypeTest : SenTestCase
@end
@implementation KWHaveReceivedInOrderMatcherSubjectTypeTest

- (void)testItCannotMatchASubjectThatIsNotATestSpy {
    STAssertFalse([KWHaveReceivedInOrderMatcher canMatchSubject:[Cruiser cruiser]],
                  @"Expected canMatchSubject: to return NO");
}

- (void)testItCanMatchASubjectThatIsATestSpy {
    id spy = [KWSpy spyForClass:[Cruiser class]];
    STAssertTrue([KWHaveReceivedInOrderMatcher canMatchSubject:spy],
                 @"Expected canMatchSubject: to return YES");
}

// Probably an unnecessary specification, if there is no way for the matcher
// to be evaluated without the verifier first checking with `+canMatchSubject:`.
// But I can't figure out a suitable test to verify this, so I'll leave this
// for now.
- (void)testMatcherShouldFailIfSubjectIsNotATestSpy {
    Cruiser *subject = [Cruiser cruiser];
    KWHaveReceivedInOrderMatcher *matcher =
        [KWHaveReceivedInOrderMatcher matcherWithSubject:subject];
    [matcher haveReceived:@selector(raiseShields)
              beforeFirst:@selector(engageHyperdrive)];
    STAssertThrowsSpecificNamed([matcher evaluate],
                                NSException,
                                @"KWMatcherException",
                                @"Expected exception because subject is not a KWSpy.");
}

@end

#endif // #if KW_TESTS_ENABLED
