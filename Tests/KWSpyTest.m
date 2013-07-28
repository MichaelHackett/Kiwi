//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "Kiwi.h"
#import "KiwiTestConfiguration.h"
#import "KWWorkarounds.h"
#import "TestClasses.h"

#if KW_TESTS_ENABLED

@interface KWClassSpyTest : SenTestCase
@property (nonatomic, strong) Class mockedClass;
@property (nonatomic, strong) id spy;
@end

@implementation KWClassSpyTest

- (void)setUp {
    self.mockedClass = [Cruiser class];
    self.spy = [KWSpy spyForClass:self.mockedClass];
}

- (void)tearDown {
    self.spy = nil;
    self.mockedClass = nil;
}

- (void)testItShouldBeInitialized {
    STAssertNotNil(self.spy, @"expected a test spy object to be initialized");
}

- (void)testItShouldAppearAsInstanceOfMockedClass {
    STAssertTrue([self.spy isMemberOfClass:self.mockedClass],
                 @"expected test spy to appear to be instance of mocked class");
}

- (void)testItShouldNotThrowAnExceptionWhenAnUnstubbedMethodIsInvoked {
#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    [self.spy computeParsecs];
    STAssertNil(KWGetAndClearExceptionFromAcrossInvocationBoundary(),
                @"expected spy to not throw exceptions for unstubbed methods");
#else
    // untested!
    STAssertNoThrow([spy computeParsecs],
                    @"expected spy to not throw exceptions for unstubbed methods");
#endif
}

- (void)testShouldRecordReceivedMessagePattern {
    [self.spy computeParsecs];
    KWMessagePattern *messagePattern =
        [KWMessagePattern messagePatternWithSelector:@selector(computeParsecs)];
    STAssertTrue([self.spy hasReceivedMessageMatchingPattern:messagePattern],
                 @"expected spy to report receiving sent message");
}

- (void)testResetShouldClearAllRecordedInvocations {
    [self.spy computeParsecs];
    [self.spy fightersInSquadron:@"one"];
    [self.spy clearRecordedInvocations];
    STAssertFalse([self.spy hasReceivedMessageMatchingPattern:
                   [KWMessagePattern messagePatternWithSelector:@selector(computeParsecs)]],
                  @"expected spy to report not having received message after reseting");
    STAssertFalse([self.spy hasReceivedMessageMatchingPattern:
                   [KWMessagePattern messagePatternWithSelector:@selector(fightersInSquadron:)]],
                  @"expected spy to report not having received message after reseting");
}

// Possibly for later, if we can come up with a method to avoid using
// NSInvocations for invoking stubs on mocks. (On non-mock objects, Kiwi
// uses dynamically generated subclasses and methods to implement stubs,
// which does solve the problem. If the same technique can be applied to
// mocks, adding a step to record invocations as well, then stubs will be
// able to throw exceptions.
// For now, since the use of exceptions is discouraged in Objective-C for
// anything but fatal errors, we'll accept that it's not necessary to be
// able to define stubs that throw them (since we don't need to write code
// to handle exceptions).
//- (void)testItShouldPassExceptionsThrownByStubbedMethod {
//    id spy = [KWSpy spyForClass:[Cruiser class]];
//    [spy stub:@selector(computeParsecs) withBlock:^id(NSArray *params) {
//        [NSException raise:@"StubThrewException" format:@"blah"];
//        return nil;
//    }];
//    STAssertThrowsSpecificNamed([spy computeParsecs],
//                                NSException,
//                                @"StubThrewException",
//                                @"expected exception from stub");
//}
//  KWClearStubsAndSpies();

@end


@interface KWProtocolSpyTest : SenTestCase
@property (nonatomic, strong) Protocol *mockedProtocol;
@property (nonatomic, strong) id spy;
@end

@implementation KWProtocolSpyTest

- (void)setUp {
    self.mockedProtocol = @protocol(JumpCapable);
    self.spy = [KWSpy spyForProtocol:self.mockedProtocol];
}

- (void)tearDown {
    self.spy = nil;
    self.mockedProtocol = nil;
}

- (void)testItShouldBeInitialized {
    STAssertNotNil(self.spy, @"expected a test spy object to be initialized");
}

- (void)testItShouldAppearToConformToMockedProtocol {
    STAssertTrue([self.spy conformsToProtocol:self.mockedProtocol],
                 @"expected spy to appear to conform to specified protocol");
}

@end

#endif
