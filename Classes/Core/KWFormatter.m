//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KWFormatter.h"

@implementation KWFormatter


#pragma mark - Getting Descriptions

+ (NSString *)formatObject:(id)anObject {
    if ([anObject isKindOfClass:[NSString class]])
        return [NSString stringWithFormat:@"\"%@\"", anObject];

    else if ([anObject isKindOfClass:[NSDictionary class]])
        return [anObject description]; // NSDictionary conforms to NSFastEnumeration

    else if ([anObject conformsToProtocol:@protocol(NSFastEnumeration)])
        return [self formattedCollection:anObject];

    return [anObject description];
}


#pragma mark - Getting Phrases

+ (NSString *)phraseForCount:(NSUInteger)aCount {
    if (aCount == 1)
        return @"1 time";

    return [NSString stringWithFormat:@"%d times", (int)aCount];
}

+ (NSString *)phraseForCountType:(KWCountType)aCountType count:(NSUInteger)aCount {
    NSString *countPhrase = [self phraseForCount:aCount];

    switch (aCountType) {
        case KWCountTypeExact:
            return [NSString stringWithFormat:@"exactly %@", countPhrase];
        case KWCountTypeAtLeast:
            return [NSString stringWithFormat:@"at least %@", countPhrase];
        case KWCountTypeAtMost:
            return [NSString stringWithFormat:@"at most %@", countPhrase];
        default:
            break;
    }

    assert(0 && "should never reach here");
    return nil;
}



#pragma mark - Private

+ (NSString *)formattedCollection:(id<NSFastEnumeration>)collection {

    NSMutableString *description = [[NSMutableString alloc] initWithString:@"("];
    NSUInteger index = 0;
    
    for (id object in collection) {
        if (index == 0)
            [description appendFormat:@"%@", [self formatObject:object]];
        else
            [description appendFormat:@", %@", [self formatObject:object]];
        
        ++index;
    }
    
    [description appendString:@")"];
    return description;
}



@end
