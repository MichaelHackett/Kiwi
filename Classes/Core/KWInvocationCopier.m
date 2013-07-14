//
// Copyright 2013 Michael Hackett. All rights reserved.
//

// It appears that [NSInvocation copy] only copies the message signature
// (well, copies the reference to it), and perhaps some other fields,
// but the frame is constructed anew, with none of the argument values
// being copied over. KWCopyInvocation is a utility function that provides
// a full duplicate of an NSInvocation that can be safely retained and
// which will be modified or reused by the runtime or program code.


#import "KWInvocationCopier.h"
#import "NSInvocation+KiwiAdditions.h"
#import "NSMethodSignature+KiwiAdditions.h"
#import <stdint.h>



/*
 * Returns the size (in bytes) of the largest visible argument in the given
 * method signature, that is, ignoring the implicit +self+ and +_cmd+
 * arguments.
 *
 * This is used by the NSInvocation copying code to allocate space for copying
 * arguments other than the target and selector (which have their own getters
 * and setters).
 */
NSUInteger KWMaxMethodArgumentLength(NSMethodSignature* methodSignature) {
    NSUInteger maxLength = 0;
    NSUInteger argumentCount = [methodSignature numberOfMessageArguments];
    for (NSUInteger index = 0; index < argumentCount; index += 1) {
        NSUInteger argumentLength =
            [methodSignature messageArgumentLengthAtIndex:index];
        if (argumentLength > maxLength) {
            maxLength = argumentLength;
        }
    }
    return maxLength;
}

NS_RETURNS_RETAINED
NSInvocation* KWCopyInvocation(NSInvocation* original) {
    NSMethodSignature* methodSignature = original.methodSignature;
    NSInvocation* copy =
        [NSInvocation invocationWithMethodSignature:methodSignature];
    [copy setTarget:[original target]];
    [copy setSelector:[original selector]];

    NSUInteger maxArgLength = KWMaxMethodArgumentLength(methodSignature);
    NSUInteger returnValueLength = [methodSignature methodReturnLength];
    if (returnValueLength > maxArgLength) {
        maxArgLength = returnValueLength;
    }

    NSMutableData* dataBuffer = [NSMutableData dataWithLength:maxArgLength];
    void* argBuffer = [dataBuffer mutableBytes];
    NSUInteger argumentCount = [methodSignature numberOfMessageArguments];
    for (NSUInteger index = 0; index < argumentCount; index += 1) {
        [original getMessageArgument:argBuffer atIndex:index];
        [copy setMessageArgument:argBuffer atIndex:index];
    }
    [original getReturnValue:argBuffer];
    [copy setReturnValue:argBuffer];

    [copy retainArguments];
    return copy;
}
