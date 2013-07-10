//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KWInvocationCopier.h"

#import "KiwiTestConfiguration.h"
#import <SenTestingKit/SenTestingKit.h>
//#import "NSInvocation+KiwiAdditions.h"
#import "NSMethodSignature+KiwiAdditions.h"
//#import "KWObjCUtilities.h"
//#import "KWStringUtilities.h"
#import <objc/runtime.h>


// TODO:
// - Unit test KWMaxMethodArgumentLength
// - Finish testing NSInvocation copier

#if KW_TESTS_ENABLED

//// Utility class to produce a valid NSInvocation object that is then copied
//// using the KWInvocationCopy method that is being tested by this module.
//
//// TODO: Is this really less work than building an NSInvocation object from
//// scratch? It seemed like a good idea at the time...
//
//@interface InvocationCapturer : NSObject
//@property (strong,nonatomic) NSValue* originalInvocationAddress;
//@property (strong,nonatomic) NSInvocation* invocationCopy;
//@end
//
//@interface InvocationCapturer (ForwardedMethods)
//- (void)msgWithString:(NSString*)stringArg object:(id)objectArg number:(int)intArg;
//@end
//
//@implementation InvocationCapturer
//
//- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
//  if (selector == @selector(msgWithString:object:number:)) {
//    return [NSMethodSignature signatureWithReturnType:@encode(void)
//                                         argumentTypes:@[@(@encode(id)),
//                                                         @(@encode(id)),
//                                                         @(@encode(int))]];
//  }
//  return [super methodSignatureForSelector:selector];
//}
//
//- (void)forwardInvocation:(NSInvocation*)invocation {
//  self.originalInvocationAddress = [NSValue valueWithNonretainedObject:invocation];
////  self.invocationCopy = [[invocation copy] autorelease];
//  self.invocationCopy = [KWCopyInvocation(invocation) autorelease];
//  [self.invocationCopy retainArguments];
//}
//
//- (void)dealloc {
//  [_originalInvocationAddress release];
//  [_invocationCopy release];
//  [super dealloc];
//}
//
//@end


static NSString* stringArg = @"Test1";
static NSArray* arrayArg;
static int intArg = 123;

@interface NSObject (DummyMethod)
- (void)msgWithString:(NSString*)stringArg object:(id)objectArg number:(int)intArg;
@end
@implementation NSObject (DummyMethod)
- (void)msgWithString:(NSString*)stringArg object:(id)objectArg number:(int)intArg {
}
@end


@interface KWInvocationCopierTest : SenTestCase

// Test fixture:
//@property (copy,nonatomic)   NSString* stringArg;
//@property (strong,nonatomic) NSArray* arrayArg;
//@property (assign,nonatomic) int intArg;
@property (strong,nonatomic) NSObject* messageReceiver;
@property (strong,nonatomic) NSMethodSignature* methodSignature;

// Test state capture:
@property (strong,nonatomic) NSValue* originalInvocationAddress;
@property (strong,nonatomic) NSInvocation* invocationCopy;
//@property (strong,nonatomic) NSValue* targetAddress;
@end

@implementation KWInvocationCopierTest

+ (void)setUp {
  arrayArg = [@[@"First", @2, @3.14159] retain];
}

+ (void)tearDown {
  [arrayArg release];
  arrayArg = nil;
}

- (NSMethodSignature*)exampleMethodSignature {
  Method targetMethod =
      class_getInstanceMethod([NSObject class],
                              @selector(msgWithString:object:number:));
  return [NSMethodSignature
          signatureWithObjCTypes:method_getTypeEncoding(targetMethod)];
}

- (void)setUp {
  // TODO: Move some of this stuff to +setUp? How to you define *class* properties?
  // (I know I'll have to use static variables, but can they have property semantics?)

//  NSString* stringArg = @"Test1";
//  NSArray* arrayArg = [NSArray arrayWithObjects:@"First", @2, @3.14159, nil];
//  int intArg = 123;

//  InvocationCapturer* invocationCapturer = [[InvocationCapturer alloc] init];
//  [invocationCapturer msgWithString:@"Test1" object:_array number:123];
//  self.originalInvocationAddress = invocationCapturer.originalInvocationAddress;
//  self.targetAddress = [NSValue valueWithNonretainedObject:invocationCapturer];
//  self.invocationCopy = invocationCapturer.invocationCopy;
//  [invocationCapturer release];

//  const char* encoding = method_getTypeEncoding(targetMethod);
//  NSLog(@"***MH*** method encoding %s", encoding);
  self.messageReceiver = [[[NSObject alloc] init] autorelease]; // dummy object to be message target
//  Method targetMethod = class_getInstanceMethod([NSObject class], @selector(msgWithString:object:number:));
  self.methodSignature = [self exampleMethodSignature];
//      [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(targetMethod)];
//      [NSMethodSignature signatureWithReturnType:@encode(void)
//                                   argumentTypes:@[@(@encode(id)),
//                                                   @(@encode(id)),
//                                                   @(@encode(int))]];

  NSInvocation* invocation =
      [NSInvocation invocationWithMethodSignature:self.methodSignature];
  invocation.target = self.messageReceiver;
  invocation.selector = @selector(msgWithString:object:number:);
  [invocation setArgument:&stringArg atIndex:2];
  [invocation setArgument:&arrayArg atIndex:3];
  [invocation setArgument:&intArg atIndex:4];
  self.originalInvocationAddress = [NSValue valueWithNonretainedObject:invocation];

  self.invocationCopy = [KWCopyInvocation(invocation) autorelease];
}

- (void)tearDown {
  self.invocationCopy = nil;
  self.originalInvocationAddress = nil;
//  self.stringArg = nil;
//  self.arrayArg = nil;
  self.messageReceiver = nil;
  self.methodSignature = nil;
}

//- (const char*)invocationArgTypeAtIndex:(NSUInteger)index {
//  return [[self.invocationCopy methodSignature]
//          messageArgumentTypeAtIndex:0];
//}

- (void)testNewInvocationWasCreated {
  STAssertNotNil(self.invocationCopy, @"expected invocation to be non-nil");
}

- (void)testInvocationCopyIsDistinctFromOriginal {
  void* original = [self.originalInvocationAddress nonretainedObjectValue];
  void* copy = (void*)self.invocationCopy;
  STAssertFalse(original == copy, @"expected copy to be a distinct object");
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

//- (void)testSecondArgumentMatchesArray {
//  id argValue;
//  [self.invocationCopy getArgument:&argValue atIndex:3];
//  STAssertEqualObjects(argValue, arrayArg,
//                       @"expected first saved argument to match given array");
//}


// TODO: test for exception with greater than 5 args

// KWMaxMethodArgumentLength tests

//- (void)testMaxArgLengthWithNoArgs {
//  NSMethodSignature* methodSignature =
//    [NSMethodSignature signatureWithObjCTypes:""];
//  STAssertEquals(4, KWMaxMethodArgumentLength(methodSignature),
//                 @"expected longest argument to be id or SEL (8 bytes)");
//}

// TODO: test that invocation arguments are retained -- [invocation argumentsRetained]

@end

#endif // #if KW_TESTS_ENABLED
