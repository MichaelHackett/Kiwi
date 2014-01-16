//
// Includes a wrapper for NSString's -rangeOfString: method that simply gives
// the YES/NO answer that is often all that one is after when trying to
// determine whether the receiver contains the specified substring. This can
// significantly simplify the client code and makes the intent much more
// clear.
//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KWSimpleContainmentTestAdditions)
- (BOOL)containsString:(NSString *)string;
@end
