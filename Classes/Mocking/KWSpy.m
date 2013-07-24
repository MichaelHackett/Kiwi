// Copyright 2013 Michael Hackett. All rights reserved.

#import "KWSpy.h"
#import "KWInvocationCopier.h"
#import "KWMessagePattern.h"
#import "NSArray+KiwiMatchAdditions.h"

//#import "KWStringUtilities.h"


@interface KWSpy ()
//@property (nonatomic, assign, readonly) Class mockedClass;
@property (nonatomic, strong, readonly) NSMutableArray *receivedInvocations; // array of NSInvocations
@end


@implementation KWSpy

#pragma mark - Initializing

- (id)initForClass:(Class)aClass {
    self = [super initAsNullMockForClass:aClass];
    if (self) {
//        _mockedClass = aClass;
        _receivedInvocations = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)spyForClass:(Class)aClass {
    return [[self alloc] initForClass:aClass];
}

//// Superclass designated initializer (?) -- non-public! (probably need to reconsider)
//- (id)initAsNullMock:(BOOL)nullMockFlag withName:(NSString *)aName forClass:(Class)aClass protocol:(Protocol *)aProtocol {
//    if ((self = [super initAsNullMock:nullMockFlag withName:aName forClass:aClass protocol:aProtocol])) {
//        receivedInvocations = [[NSMutableArray alloc] init];
//    }
//
//    return self;
//}

// Alternate designated initializer. (Bad design?)
//- (id)initAsPartialMockWithName:(NSString *)aName forObject:(id)object {
//
//}

#pragma mark - Recording messages

// Records the given invocation in the list of messages received by this
// object. A copy is made in order to preserve the argument values, in case
// the invocation is reused. (Note, however, that the arguments themselves
// are not copies, so if they are mutable objects and are changed later,
// this will affect the recorded argument values. Argument tests should be
// limited to the argument value itself (a scalar value or an object
// pointer), unless the objects are known to be immutable.

- (void)recordInvocation:(NSInvocation *)invocation {
    NSInvocation *invocationCopy = KWCopyInvocation(invocation);
    [invocationCopy retainArguments];
    [self.receivedInvocations addObject:invocationCopy];
}


#pragma mark - Verification

//- (BOOL)hasReceivedMessage:(SEL)selector {
//    KWMessagePattern *messagePattern =
//        [KWMessagePattern messagePatternWithSelector:selector];
//    return [self hasReceivedInvocationMatchingMessagePattern:messagePattern];
//}

- (BOOL)hasReceivedMessageMatchingPattern:(KWMessagePattern*)pattern {
    return ([self.receivedInvocations containsObjectPassingTest:^(id invocation, NSUInteger index, BOOL *stop) {
        return [pattern matchesInvocation:invocation];
    }]);
}


#pragma mark - Handling invocations (private)

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature *methodSignature =
//        [self.mockedClass instanceMethodSignatureForSelector:aSelector];
////    if (methodSignature == nil) {
////        methodSignature = [self mockedProtocolMethodSignatureForSelector:aSelector];
////    }
//    if (methodSignature == nil) {
//        NSString *encoding = KWEncodingForVoidMethod();
//        methodSignature = [NSMethodSignature signatureWithObjCTypes:[encoding UTF8String]];
//    }
//    return methodSignature;
//}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self recordInvocation:invocation];
    [super forwardInvocation:invocation];
}

@end
