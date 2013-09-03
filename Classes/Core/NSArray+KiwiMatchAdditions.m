//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "NSArray+KiwiMatchAdditions.h"

@implementation NSArray (KiwiMatchAdditions)

// Optimization of below, when only need to know if the test passes at least once.
// (not currently used in Kiwi code)
//- (BOOL)containsObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
//    return ([self indexOfObjectPassingTest:predicate] == NSNotFound) ? NO : YES;
//}

- (NSUInteger)countOfObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate {
    return [[self indexesOfObjectsPassingTest:predicate] count];
}

@end
