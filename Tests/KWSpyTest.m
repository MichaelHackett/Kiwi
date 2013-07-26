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

@interface KWSpyTest : SenTestCase
@end

@implementation KWSpyTest
{
    // test fixture ivars go here
}

- (void)testItShouldInitializeForAClass {
    id mockedClass = [Cruiser class];
//    id name = @"Car mock";
    id spy = [KWSpy spyForClass:mockedClass];
    STAssertNotNil(spy, @"expected a test spy object to be initialized");
//    STAssertEqualObjects([spy mockedClass], mockedClass,
//                         @"expected the mockedClass property to be set");
//    STAssertEqualObjects([mock mockName], @"Car mock", @"expected class mock to have the correct mockName");
}

- (void)testClassSpyShouldAppearAsInstanceOfMockedClass {
    id mockedClass = [Cruiser class];
    id spy = [KWSpy spyForClass:mockedClass];
    STAssertTrue([spy isMemberOfClass:mockedClass],
                 @"expected test spy to appear to be instance of mocked class");
}

- (void)testItShouldNotThrowAnExceptionWhenAnUnstubbedMethodIsInvoked {
    id spy = [KWSpy spyForClass:[Cruiser class]];
#if KW_TARGET_HAS_INVOCATION_EXCEPTION_BUG
    [spy computeParsecs];
    STAssertNil(KWGetAndClearExceptionFromAcrossInvocationBoundary(),
                @"expected spy to not throw exceptions for unstubbed methods");
#else
    // untested!
    STAssertNoThrow([spy computeParsecs],
                    @"expected spy to not throw exceptions for unstubbed methods");
#endif
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

- (void)testItShouldInitializeForAProtocol {
    id mockedProtocol = @protocol(JumpCapable);
//    id name = @"JumpCapable mock";
    id spy = [KWSpy spyForProtocol:mockedProtocol];
    STAssertNotNil(spy, @"expected a test spy object to be initialized");
//    STAssertEqualObjects([mock mockName], @"JumpCapable mock", @"expected class mock to have the correct mockName");
}

- (void)testProtocolSpyShouldAppearToConformToMockedProtocol {
    id mockedProtocol = @protocol(JumpCapable);
    //    id name = @"JumpCapable mock";
    id spy = [KWSpy spyForProtocol:mockedProtocol];
    STAssertTrue([spy conformsToProtocol:mockedProtocol],
                 @"expected spy to appear to conform to specified protocol");
}

@end

#endif
