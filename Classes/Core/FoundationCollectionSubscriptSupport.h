// Compatibility declarations to allow NSArray and NSDictionary shorthand
// subscripting with SDKs prior to iOS 6 and OSX 10.8.
//
// The compiler (since at least Xcode 4.4+) only needs to see these
// declarations in order to emit the appropriate method calls. The
// implementations are available to any ARC-enabled code using the libarclite
// library that is automatically linked in for earlier OS targets.
//
// See:
//     http://lists.apple.com/archives/cocoa-dev/2012/Aug/msg00636.html
//     http://lists.apple.com/archives/cocoa-dev/2012/Aug/msg00640.html
// or:
//     http://www.cocoabuilder.com/archive/cocoa/321091-how-to-make-obj-collection-subscripting-work-on-ios-5.html
//
// Licensed under the terms in License.txt
//
// Copyright 2014 Michael Hackett. All rights reserved.
//

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 60000)

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>

@interface NSArray (KWFoundationSubscriptSupport)
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end

@interface NSMutableArray (KWFoundationSubscriptSupport)
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
@end

@interface  NSDictionary (KWFoundationSubscriptSupport)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface  NSMutableDictionary (KWFoundationSubscriptSupport)
- (void)setObject:(id)object forKeyedSubscript:(id)key;
@end

#endif
