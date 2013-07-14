//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "NSMethodSignature+KiwiAdditions.h"

#import <SenTestingKit/SenTestingKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "KiwiTestConfiguration.h"


#if KW_TESTS_ENABLED

@interface KWMethodSignatureAdditionsTestDummyClass : NSObject
- (void)msgWithString:(NSString*)stringArg
                float:(double)floatArg
            structure:(CGRect)structArg;
@end
@implementation KWMethodSignatureAdditionsTestDummyClass
- (void)msgWithString:(NSString*)stringArg
                float:(double)floatArg
            structure:(CGRect)structArg
{
}
@end

@interface KWMethodSignatureAdditionsTest : SenTestCase
@property (strong,nonatomic) NSMethodSignature* methodSignature;
@end

@implementation KWMethodSignatureAdditionsTest

- (void)setUp {
    self.methodSignature =
        [KWMethodSignatureAdditionsTestDummyClass
         instanceMethodSignatureForSelector:
             @selector(msgWithString:float:structure:)];
}

- (void)tearDown {
    self.methodSignature = nil;
}

- (void)testLengthOfIdArgument {
    STAssertEquals([self.methodSignature messageArgumentLengthAtIndex:0],
                   (NSUInteger)sizeof(id),
                   @"length of id argument is wrong");
}

- (void)testLengthOfDoubleArgument {
  STAssertEquals([self.methodSignature messageArgumentLengthAtIndex:1],
                 (NSUInteger)sizeof(double),
                 @"length of double argument is wrong");
}

- (void)testLengthOfStructArgument {
  STAssertEquals([self.methodSignature messageArgumentLengthAtIndex:2],
                 (NSUInteger)sizeof(CGRect),
                 @"length of CGRect argument is wrong");
}

@end

#endif
