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

// TODO: Could use one of the Kiwi test classes instead
@interface KWInvocationCopierTestDummyClass : NSObject
@end
@implementation KWInvocationCopierTestDummyClass
- (double)msgWithString:(NSString*)stringArg
                 object:(id)objectArg
                 number:(int)intArg
{ return 0.0; }

- (void)voidMethod { }
- (void)voidReturnWithObject:(id)objectArg { }
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

+ (NSInvocation*)createOriginalInvocation:(id)receiver {
    NSAssert(NO, @"subclasses of KWInvocationCopierTest must override +createOriginalInvocation:");
    return nil;
}

// Make the base class abstract, so its test methods are not run on itself,
// only on subclasses.
+ (id)defaultTestSuite {
    if ([self isEqual:[KWInvocationCopierTest class]]) {
        return nil;
    }
    return [super defaultTestSuite];
}

- (void)setUp {
    // dummy object to be message target
    self.messageReceiver = [[[KWInvocationCopierTestDummyClass alloc] init] autorelease];
    self.originalInvocation = [[self class] createOriginalInvocation:self.messageReceiver];
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
    STAssertTrue(self.invocationCopy.selector == self.originalInvocation.selector,
                 @"expected target in copy to be the same as in original");
}

// The reason for not retaining the invocation arguments in the copy, even if
// retained in the original, is that there is no way to *un*retain the
// arguments, if the caller did not want that. In order to leave the choice up
// to the caller, the copy should start with arguments unretained and the
// owner of the copy can make the call to retain them if desired.
- (void)testThatArgumentsAreNotRetainedInCopy {
    STAssertFalse([self.invocationCopy argumentsRetained],
                  @"expected arguments to not be retained in copy");
}

@end


@interface KWInvocationCopierMixedMethodTest : KWInvocationCopierTest
@end

@implementation KWInvocationCopierMixedMethodTest

+ (void)setUp {
    arrayArg = [@[@"First", @2, @3.14159] retain];
}

+ (void)tearDown {
    [arrayArg release];
    arrayArg = nil;
}

+ (NSInvocation*)createOriginalInvocation:(id)receiver {
    NSInvocation* invocation =
        [NSInvocation invocationWithTarget:receiver
                                  selector:@selector(msgWithString:object:number:)
                          messageArguments:&stringArg, &arrayArg, &intArg, nil];
    [invocation setReturnValue:&returnValue];
    return invocation;
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

- (void)testThirdArgumentMatchesInteger {
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

- (void)testThatReturnValueIsSetInCopy {
    double argValue;
    [self.invocationCopy getReturnValue:&argValue];
    STAssertEquals(argValue, returnValue,
                   @"expected return value to be same as in original");
}

@end



@interface KWInvocationCopierVoidMethodTest : KWInvocationCopierTest
@end

@implementation KWInvocationCopierVoidMethodTest

+ (NSInvocation*)createOriginalInvocation:(id)receiver {
    return [NSInvocation invocationWithTarget:receiver
                                     selector:@selector(voidMethod)
                             messageArguments:nil];
}

- (void)testThatThereAreOnlyTheTwoHiddenArguments {
    id argValue;
    STAssertThrowsSpecificNamed(
        [self.invocationCopy getArgument:&argValue atIndex:2],
        NSException, NSInvalidArgumentException,
        @"asked for invalid argument index; expected exception"
    );
}

@end



@interface KWInvocationCopierVoidReturnWithArgumentsTest : KWInvocationCopierTest
@end

@implementation KWInvocationCopierVoidReturnWithArgumentsTest

+ (NSInvocation*)createOriginalInvocation:(id)receiver {
    return [NSInvocation invocationWithTarget:receiver
                                     selector:@selector(voidReturnWithObject:)
                             messageArguments:&arrayArg, nil];
}

- (void)testFirstArgumentMatchesArray {
    id argValue;
    [self.invocationCopy getArgument:&argValue atIndex:2];
    STAssertEqualObjects(argValue, arrayArg,
                         @"expected first saved argument to match given array");
}

- (void)testThatThereAreOnlyThreeArgumentsInTotal {
    id argValue;
    STAssertThrowsSpecificNamed(
        [self.invocationCopy getArgument:&argValue atIndex:3],
        NSException, NSInvalidArgumentException,
        @"asked for invalid argument index; expected exception"
    );
}

@end

#endif // #if KW_TESTS_ENABLED
