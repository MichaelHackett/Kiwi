//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWInvocationCopier.h"

#import <objc/runtime.h>
#import <SenTestingKit/SenTestingKit.h>
#import "NSInvocation+KiwiAdditions.h"
#import "KiwiTestConfiguration.h"

#if KW_TESTS_ENABLED

static NSString* stringArg = @"Test1";
static NSArray* arrayArg;
static int intArg = 123;
static double returnValue = 2.71828;

@interface KWInvocationCopierTestDummyClass : NSObject
@end
@implementation KWInvocationCopierTestDummyClass
- (double)msgWithString:(NSString*)stringArg
                 object:(id)objectArg
                 number:(int)intArg
{ return 0.0; }
@end

@interface KWInvocationCopierTest : SenTestCase

// Test fixture:
@property (strong,nonatomic) NSObject* messageReceiver;
@property (strong,nonatomic) NSMethodSignature* methodSignature;

// Test state capture:
@property (strong,nonatomic) NSInvocation* originalInvocation;
@property (strong,nonatomic) NSInvocation* invocationCopy;
@end

@implementation KWInvocationCopierTest

+ (void)setUp {
    arrayArg = [@[@"First", @2, @3.14159] retain];
}

+ (void)tearDown {
    [arrayArg release];
    arrayArg = nil;
}

- (void)setUp {
    // dummy object to be message target
    self.messageReceiver = [[[KWInvocationCopierTestDummyClass alloc] init]
                            autorelease];

    self.originalInvocation =
        [NSInvocation invocationWithTarget:self.messageReceiver
                                  selector:@selector(msgWithString:object:number:)
                          messageArguments:&stringArg, &arrayArg, &intArg, nil];
    [self.originalInvocation setReturnValue:&returnValue];

    self.methodSignature = self.originalInvocation.methodSignature;

    self.invocationCopy = [KWCopyInvocation(self.originalInvocation) autorelease];
}

- (void)tearDown {
    self.invocationCopy = nil;
    self.originalInvocation = nil;
    self.messageReceiver = nil;
    self.methodSignature = nil;
}

- (void)testNewInvocationWasCreated {
    STAssertNotNil(self.invocationCopy, @"expected invocation to be non-nil");
}

- (void)testInvocationCopyIsDistinctFromOriginal {
    STAssertFalse(self.invocationCopy == self.originalInvocation,
                  @"expected copy to be a distinct object");
}

- (void)testMethodSignatureIsSameInCopy {
    STAssertEqualObjects(self.methodSignature,
                         self.invocationCopy.methodSignature,
                         @"expected copy to have the same method signature");
}

- (void)testTargetIsSameInCopy {
    STAssertTrue(self.invocationCopy.target == self.messageReceiver,
                 @"expected target in copy to be the same as in original");
}

- (void)testSelectorIsSameInCopy {
    STAssertTrue(self.invocationCopy.selector ==
                 @selector(msgWithString:object:number:),
                 @"expected target in copy to be the same as in original");
}

- (void)testFirstArgumentMatchesString {
    id argValue;
    [self.invocationCopy getArgument:&argValue atIndex:2];
    STAssertEqualObjects(argValue, stringArg,
                         @"expected first saved argument to match given string");
}

- (void)testSecondArgumentMatchesArray {
    id argValue;
    [self.invocationCopy getArgument:&argValue atIndex:3];
    STAssertEqualObjects(argValue, arrayArg,
                         @"expected second saved argument to match given array");
}

- (void)testThirdArgumentMatchesArray {
    int argValue;
    [self.invocationCopy getArgument:&argValue atIndex:4];
    STAssertEquals(argValue, intArg,
                   @"expected third saved argument to match given int");
}

- (void)testThatThereAreOnlyThreeVisibleArguments {
    id argValue;
    STAssertThrowsSpecificNamed(
        [self.invocationCopy getArgument:&argValue atIndex:5],
        NSException, NSInvalidArgumentException,
        @"asked for invalid argument index; expected exception"
    );
}

- (void)testThatArgumentsAreRetainedInCopy {
    STAssertTrue([self.invocationCopy argumentsRetained],
                 @"expected arguments to be retained in copy");
}

- (void)testThatReturnValueIsSetInCopy {
    double argValue;
    [self.invocationCopy getReturnValue:&argValue];
    STAssertEquals(argValue, returnValue,
                   @"expected return value to be same as in original");
}

@end

#endif // #if KW_TESTS_ENABLED
