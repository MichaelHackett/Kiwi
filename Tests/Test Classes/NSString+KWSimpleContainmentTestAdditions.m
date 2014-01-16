//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "NSString+KWSimpleContainmentTestAdditions.h"

@implementation NSString (KWSimpleContainmentTestAdditions)

- (BOOL)containsString:(NSString *)string {
    NSRange matchRange = [self rangeOfString:string];
    return matchRange.location != NSNotFound;
}

@end
