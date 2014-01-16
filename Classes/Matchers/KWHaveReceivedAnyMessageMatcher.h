//
// Licensed under the terms in License.txt
//
// Copyright 2013 Michael Hackett. All rights reserved.
//

#import "KiwiConfiguration.h"
#import "KWMatcher.h"

@interface KWHaveReceivedAnyMessageMatcher : KWMatcher

//@property (nonatomic, assign) BOOL willEvaluateMultipleTimes;

#pragma mark - Configuring Matchers

- (void)haveReceivedAnyMessages;
- (void)haveReceivedSomeMessage;

@end
