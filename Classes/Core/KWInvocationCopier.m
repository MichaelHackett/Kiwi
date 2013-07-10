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

#import "NSMethodSignature+KiwiAdditions.h"

NS_RETURNS_RETAINED
NSInvocation* KWCopyInvocation(NSInvocation* original) {
  NSMethodSignature* methodSignature = original.methodSignature;
  NSInvocation* copy =
      [NSInvocation invocationWithMethodSignature:methodSignature];
  [copy setTarget:[original target]];
  [copy setSelector:[original selector]];

//  NSMutableData* dataBuffer =
//      [NSMutableData dataWithLength:KWMaxMethodArgumentLength(methodSignature)];
//  void* argumentBuffer = [dataBuffer mutableBytes];
//  NSUInteger argumentCount = [methodSignature numberOfArguments];
//  for (NSUInteger argumentIndex = 0; argumentIndex < argumentCount; argumentIndex += 1) {
//    [original getArgument:argumentBuffer atIndex:argumentIndex];
//    [copy setArgument:argumentBuffer atIndex:argumentIndex];
//  }
  id argValue;
  [original getArgument:&argValue atIndex:2];
  [copy setArgument:&argValue atIndex:2];

  //  void* argumentBuffer = malloc(sizeof(id));
  //  [original getArgument:argumentBuffer atIndex:2];
  //  [copy setArgument:argumentBuffer atIndex:2];
  //  free(argumentBuffer);
  // getArgument:atIndex:
  // setArgument:atIndex:
  // setReturnValue:
  return copy;
}
