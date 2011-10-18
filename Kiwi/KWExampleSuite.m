//
//  KWExampleSuite.m
//  Kiwi
//
//  Created by Luke Redpath on 17/10/2011.
//  Copyright (c) 2011 Allen Ding. All rights reserved.
//

#import "KWExampleSuite.h"
#import "KWExampleGroup.h"
#import "KWStringUtilities.h"
#import "KWBeforeAllNode.h"
#import "KWAfterAllNode.h"
#import "NSMethodSignature+KiwiAdditions.h"
#import <objc/runtime.h>


@implementation KWExampleSuite

- (id)initWithRootNode:(KWContextNode *)contextNode
{
  if ((self = [super init])) {
    rootNode = [contextNode retain];
    exampleGroups = [[NSMutableSet alloc] init];
    visitedNodes = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void)dealloc 
{
  [visitedNodes release];
  [exampleGroups release];
  [rootNode release];
  [super dealloc];
}

- (void)addExampleGroup:(KWExampleGroup *)exampleGroup
{
  [exampleGroups addObject:exampleGroup];
  [exampleGroup setSuite:self];
}

- (NSArray *)invocationsForTestCase;
{
  NSMutableArray *invocations = [NSMutableArray array];
  
  for (KWExampleGroup *exampleGroup in exampleGroups) {
    // Add a single dummy invocation for each example group
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:[KWEncodingForVoidMethod() UTF8String]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    [invocations addObject:invocation];
    
    // because SenTest will modify the invocation target, we'll have to store 
    // another reference to the example group so we can retrieve it later
    objc_setAssociatedObject(invocation, kKWINVOCATION_EXAMPLE_GROUP_KEY, exampleGroup, OBJC_ASSOCIATION_RETAIN);    
  }
  
  return invocations;
}

#pragma mark - Node visiting

- (void)visitBeforeAllNode:(KWBeforeAllNode *)aNode {
  if (aNode.block == nil || [visitedNodes containsObject:aNode])
    return;
  
  [visitedNodes addObject:aNode];
  
  aNode.block();
}

- (void)visitAfterAllNode:(KWAfterAllNode *)aNode {
  if (aNode.block == nil || [visitedNodes containsObject:aNode])
    return;
  
  [visitedNodes addObject:aNode];
  
  aNode.block();
}

@end
