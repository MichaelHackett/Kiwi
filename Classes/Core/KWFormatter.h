//
// Licensed under the terms in License.txt
//
// Copyright 2010 Allen Ding. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWCountType.h"

@interface KWFormatter : NSObject

#pragma mark - Getting Descriptions

+ (NSString *)formatObject:(id)anObject;

#pragma mark - Getting Phrases

+ (NSString *)phraseForCount:(NSUInteger)aCount;
+ (NSString *)phraseForCountType:(KWCountType)aCountType count:(NSUInteger)aCount;

@end
