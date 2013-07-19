//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "NSArray+KiwiMatchAdditions.h"

@implementation NSArray (KiwiMatchAdditions)

- (BOOL)containsObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    return ([self indexOfObjectPassingTest:predicate] == NSNotFound) ? NO : YES;
}

@end
