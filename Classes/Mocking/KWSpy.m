// Copyright 2013 Michael Hackett. All rights reserved.

#import "KWSpy.h"
#import "KWInvocationCopier.h"
#import "KWMessagePattern.h"
#import "NSArray+KiwiMatchAdditions.h"

//#import "KWStringUtilities.h"


// NOTE: The mockedClass property does not appear to be used within Kiwi
// outside of the KWMock class, and if the -class method was overridden
// to return the mocked class, there would be no need to expose it as a
// separate property at all. (It could be private to the class.) I'm not
// sure if it's smart to override -class or not, so I'll let that stew
// for a while, but in any case, -isKindOfClass and -isMemberOfClass
// *have* been overridden to function based on the mocked class, so I'll
// need to look at recommended practices to see if anyone uses -class
// directly.

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

- (id)initForProtocol:(Protocol *)aProtocol {
    self = [super initAsNullMockForProtocol:aProtocol];
    if (self) {
//        _mockedClass = aClass;
        _receivedInvocations = [[NSMutableArray alloc] init];
    }
    return self;
}

// For later, after refactoring parent class; currently, its designated
// initializer is private, so it would be dodgy to call it from here.
// This results in some duplication above, but it's minor thus far.

//- (id)initForClass:(Class)aClass protocol:(Protocol *)aProtocol {
//    self = [super initAsNullMock:YES
//                        withName:nil
//                        forClass:aClass
//                        protocol:aProtocol];
//    if (self) {
//        _receivedInvocations = [[NSMutableArray alloc] init];
//    }
//
//    return self;
//}

// Block all superclass constructors, except those explicitly overridden in
// this class, by overriding the superclass designated initializer.
//- (id)initAsNullMock:(BOOL)nullMockFlag
//            withName:(NSString *)aName
//            forClass:(Class)aClass
//            protocol:(Protocol *)aProtocol
//{
//    [self doesNotRecognizeSelector:_cmd];
//    return nil;
//}
// FIXME: Can't do this while our initializer above calls a superclass
// initializer besides the designated initializer (because the other
// initializer will forward to this method and generate the exception).
// However, we run into trouble trying to call the designated initializer
// because it's not public. In any case, this issue can be solved by
// extracting a new common superclass (e.g. KWTestDouble) that both KWSpy
// and KWMock can inherit from.

+ (id)spyForClass:(Class)aClass {
    return [[self alloc] initForClass:aClass];
}

+ (id)spyForProtocol:(Protocol *)aProtocol {
    return [[self alloc] initForProtocol:aProtocol];
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

- (void)clearRecordedInvocations {
    [self.receivedInvocations removeAllObjects];
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
