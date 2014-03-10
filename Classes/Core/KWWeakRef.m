// Copyright 2014 Michael Hackett. All rights reserved.
//
// Based on code posted by "Timo" on Stack Overflow:
//     http://stackoverflow.com/a/18080450/686385


#import "KWWeakRef.h"

@implementation KWWeakRef

+ (id)weakRefTo:(id)object {
    return [[self alloc] initWithObject:object];
}

- (id)initWithObject:(id)object {
    // NSProxy does not define any initializers.
    _KWWeakRef_weakRef = object;
    return self;
}

// Seems like forwardingTargetForSelector is not being called for proxies. Confirm?
//- (id)forwardingTargetForSelector:(SEL)selector {
//    return self.KWWeakRef_weakRef;
//}

- (void)forwardInvocation:(NSInvocation *)invocation {
    invocation.target = self.KWWeakRef_weakRef;
    [invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    id ref = self.KWWeakRef_weakRef;
    return [ref methodSignatureForSelector:sel];
}

- (NSString *)description {
    id ref = self.KWWeakRef_weakRef;
    return [ref description];
}

- (NSString *)debugDescription {
    id ref = self.KWWeakRef_weakRef;
    return [ref debugDescription];
}

@end
