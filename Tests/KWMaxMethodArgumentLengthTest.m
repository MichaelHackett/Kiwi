//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWInvocationCopier.h"

#import "KiwiTestConfiguration.h"
#import <SenTestingKit/SenTestingKit.h>
#import <CoreGraphics/CGGeometry.h>

#if KW_TESTS_ENABLED

@interface KWMaxMethodArgumentLengthTestDummyClass : NSObject
@end
@implementation KWMaxMethodArgumentLengthTestDummyClass
- (void)voidMessage {}
- (void)msgWithObject:(NSObject*)objArg {}
- (void)msgWithInt:(int)intArg {}
- (void)msgWithDouble:(double)doubleArg {}
- (void)msgWithFirstObject:(NSObject*)objArg1
              secondObject:(NSString*)objArg2 {}
- (void)msgWithSmall:(short int)shortIntArg
               large:(CGRect)rectArg
              medium:(id)objArg {}
@end


@interface KWMaxMethodArgumentLengthTest : SenTestCase
@end

@implementation KWMaxMethodArgumentLengthTest

- (void)testMaxArgLengthWithNoArgs {
    NSMethodSignature* methodSignature =
         [KWMaxMethodArgumentLengthTestDummyClass
          instanceMethodSignatureForSelector:@selector(voidMessage)];

    STAssertEquals(KWMaxMethodArgumentLength(methodSignature),
                   (NSUInteger)0,
                   @"no arguments, so expected result to be 0 bytes");
}

- (void)testMaxArgLengthWithOneObjectArg {
    NSMethodSignature* methodSignature =
        [KWMaxMethodArgumentLengthTestDummyClass
         instanceMethodSignatureForSelector:@selector(msgWithObject:)];

    STAssertEquals(KWMaxMethodArgumentLength(methodSignature),
                   (NSUInteger)sizeof(NSObject*),
                   @"expected largest argument to be size of a pointer");
}

- (void)testMaxArgLengthWithOneIntArg {
    NSMethodSignature* methodSignature =
    [KWMaxMethodArgumentLengthTestDummyClass
     instanceMethodSignatureForSelector:@selector(msgWithInt:)];

    STAssertEquals(KWMaxMethodArgumentLength(methodSignature),
                   (NSUInteger)sizeof(int),
                   @"expected largest argument to be size of an int");
}

- (void)testMaxArgLengthWithOneDoubleArg {
    NSMethodSignature* methodSignature =
    [KWMaxMethodArgumentLengthTestDummyClass
     instanceMethodSignatureForSelector:@selector(msgWithDouble:)];

    STAssertEquals(KWMaxMethodArgumentLength(methodSignature),
                   (NSUInteger)sizeof(double),
                   @"expected largest argument to be size of an double");
}

- (void)testMaxArgLengthWithTwoObjectArgs {
    NSMethodSignature* methodSignature =
    [KWMaxMethodArgumentLengthTestDummyClass
     instanceMethodSignatureForSelector:@selector(msgWithFirstObject:secondObject:)];

    STAssertEquals(KWMaxMethodArgumentLength(methodSignature),
                   (NSUInteger)sizeof(id),
                   @"expected largest argument to be size of a pointer");
}

- (void)testMaxArgLengthWithMixedArgs {
    NSMethodSignature* methodSignature =
    [KWMaxMethodArgumentLengthTestDummyClass
     instanceMethodSignatureForSelector:@selector(msgWithSmall:large:medium:)];

    STAssertEquals(KWMaxMethodArgumentLength(methodSignature),
                   (NSUInteger)sizeof(CGRect),
                   @"expected largest argument to be size of a CGRect structure");
}

@end

#endif