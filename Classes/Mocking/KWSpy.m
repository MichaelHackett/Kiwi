// Copyright 2013-4 Michael Hackett. All rights reserved.

#import "KWSpy.h"
#import "KWInvocationCopier.h"
#import "KWMessagePattern.h"
#import "KWObjCUtilities.h"
#import "KWWeakRef.h"
#import "NSArray+KiwiMatchAdditions.h"


// Internal helper functions
static void replaceTargetWithWeakRef(NSInvocation *invocation);
static void copyBlockArguments(NSInvocation *invocation);


// NOTE: The mockedClass property does not appear to be used within Kiwi
// outside of the KWMock class, and if the -class method was overridden
// to return the mocked class, there would be no need to expose it as a
// separate property at all. (It could be private to the class.) I'm not
// sure if it's smart to override -class or not, so I'll let that stew
// for a while, but in any case, -isKindOfClass and -isMemberOfClass
// *have* been overridden to function based on the mocked class, so I'll
// need to look at recommended practices to see if anyone uses -class
// directly.

//@interface KWSpy ()
//@property (nonatomic, assign, readonly) Class mockedClass;
//@end


@implementation KWSpy
{
    // array of NSInvocations received by spy
    NSMutableArray* _receivedInvocations;
}


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


#pragma mark - Properties

- (NSArray *)receivedInvocations {
    // Returns an immutable copy of the spy's invocation record.
    return [NSArray arrayWithArray:_receivedInvocations];
}


#pragma mark - Recording messages

// Records the given invocation in the list of messages received by this
// object. A copy is made in order to preserve the argument values, in case
// the invocation is reused. (Note, however, that the arguments themselves
// are not copies, so if they are mutable objects and are changed later,
// this will affect the recorded argument values. Argument tests should be
// limited to the argument value itself (a scalar value or an object
// pointer), unless the objects are known to be immutable.
//
// The target object reference (which will be the spy itself) is wrapped in
// a "weak reference" object to avoid a retain loop. It is still possible
// to create a loop if the spy is passed as a method argument, or is held
// in a strong reference by any of the objects in the arguments, but this
// would be almost impossible to prevent and likely fairly rare in
// practice, so hopefully the occasional leak will in a spec will not be
// too detrimental. If this is not acceptable, the alternative is to
// record invocations in the Example and clear them out at the end of
// the example.

- (void)recordInvocation:(NSInvocation *)anInvocation {
    NSInvocation *invocationCopy = KWCopyInvocation(anInvocation);
    replaceTargetWithWeakRef(invocationCopy);
    copyBlockArguments(invocationCopy);
    [invocationCopy retainArguments];
    [_receivedInvocations addObject:invocationCopy];
}

- (void)clearRecordedInvocations {
    [_receivedInvocations removeAllObjects];
}


#pragma mark - Handling invocations (private)

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self recordInvocation:invocation];
    [super forwardInvocation:invocation];
}

@end



#pragma mark - Internal helper functions

void replaceTargetWithWeakRef(NSInvocation *invocation) {
    invocation.target = [KWWeakRef weakRefTo:invocation.target];
}

// The block copies are autoreleased, to prevent a leak when they are
// retained by the invocation. Ensure there is no autorelease-pool block
// separating the call to this function and asking the invocation to retain
// the arguments, otherwise the block objects may be deallocated.
void copyBlockArguments(NSInvocation *invocation) {
    NSMethodSignature *methodSig = invocation.methodSignature;
    NSUInteger argCount = [methodSig numberOfArguments];
    for (NSUInteger argIndex = 2; argIndex < argCount; argIndex++) {
        if (KWObjCTypeIsBlock([methodSig getArgumentTypeAtIndex:argIndex])) {
            __unsafe_unretained id origBlock;
            [invocation getArgument:&origBlock atIndex:argIndex];
            __autoreleasing id blockCopy = [origBlock copy];
            [invocation setArgument:(void *)&blockCopy atIndex:argIndex];
        }
    }
}
