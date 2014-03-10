//
// KWWeakRef:
//     A wrapper to turn strong references into weak references.
//
// There are often cases where we want to use a class that uses strong
// references to objects (for example, the Foundation collection classes) but
// such a use would create a retain loop that we wish to avoid.
//
// To work around this, wrap the reference in a KWWeakRef, and then pass the
// KWWeakRef instead. The receiver will retain the wrapper, which will *not*
// retain the original object, breaking the loop.
//
// Additionally, the wrapper acts as a proxy that can be messaged as if it
// were the real object (at a slight performance cost).
//
// To check whether the weak reference itself is still valid (non-nil), it is
// available as a separate property on the proxy (named so that a conflict
// with the wrapped object is extremely unlikely).
//
// Based on (public domain?) code posted by "Timo" on Stack Overflow:
//     http://stackoverflow.com/a/18080450/686385
//

#import "KiwiConfiguration.h"

@interface KWWeakRef : NSProxy

@property (weak, readonly, nonatomic) id KWWeakRef_weakRef;

+ (id)weakRefTo:(id)object;

- (id)initWithObject:(id)object;

@end
