//
//  FOSortedSet.m
//  DataStructures
//
//  Created by Fredrik Olsson on 10/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "FOSortedSet.h"
#import "FOBlockEnumerator.h"
#import <objc/message.h>

@interface FOTreeNode : NSObject
@property (nonatomic, strong) id object;
@property (nonatomic, weak) FOTreeNode *parentNode;
@property (nonatomic, strong) FOTreeNode *lessThanNode;
@property (nonatomic, strong) FOTreeNode *greaterThanNode;

- (NSUInteger)count;
- (void)invalidateCount;

@end


/*
 * Implementation notes. The implementation is based on a binary search tree.
 * The rank of a node in the search tree relative to the root node is also
 * the index of the object.
 *
 * The object enumerator block is quite gnarly since it can not be recursive,
 * and must be re-entrant. For smaller sets it is probably better to create a
 * static array instead of traversing the tree.
 */
@implementation FOSortedSet {
  __strong NSComparator _comparator;
  FOTreeNode *_rootNode;
}

- (instancetype)initWithComparator:(NSComparator)comparator;
{
  self = [self init];
  if (self) {
    _comparator = [comparator copy];
  }
  return self;
}

- (instancetype)initWithSortDescriptors:(NSArray *)sortDescriptors;
{
  NSParameterAssert([sortDescriptors count] > 0);
  // Create a NSComparator block for the given sort descriptors and pass to designated initializer.
  return [self initWithComparator:^NSComparisonResult(id obj1, id obj2) {
    NSComparisonResult result;
    for (NSSortDescriptor *sortDescriptor in sortDescriptors) {
      result = [sortDescriptor compareObject:obj1 toObject:obj2];
      if (result != NSOrderedSame) {
        break;
      }
    }
    return result;
  }];
}

- (instancetype)initWithCompareSelector:(SEL)compareSelector;
{
  NSParameterAssert(compareSelector != NULL);
  // Create a NSComparator block for the given comparison selector and pass to designated initializer.
  return [self initWithComparator:^NSComparisonResult(id obj1, id obj2) {
    // Use a casted direct call to message dispatch to avoid potential leaks under ARC with performSelector:withObject:
    NSComparisonResult(*castedMsgSend)(id,SEL,id) = (void *)objc_msgSend;
    return castedMsgSend(obj1, compareSelector, obj2);
  }];
}

#pragma mark -
#pragma mark Private helper methods

- (FOTreeNode *)nodeWithObject:(id)object inTreeNode:(FOTreeNode *)node;
{
  if (node != nil) {
    NSComparisonResult result = _comparator(object, node.object);
    switch (result) {
      case NSOrderedAscending:
        return [self nodeWithObject:object inTreeNode:node.lessThanNode];
      case NSOrderedDescending:
        return [self nodeWithObject:object inTreeNode:node.greaterThanNode];
      default:
        return node;
    }
  }
  return nil;
}

- (FOTreeNode *)addObject:(id)object toTreeNode:(FOTreeNode *)node;
{
  if (node == nil) {
    node = [[FOTreeNode alloc] init];
    node.object = object;
  } else {
    NSComparisonResult result = _comparator(object, node.object);
    switch (result) {
      case NSOrderedAscending:
        node.lessThanNode = [self addObject:object toTreeNode:node.lessThanNode];
        break;
      case NSOrderedDescending:
        node.greaterThanNode = [self addObject:object toTreeNode:node.greaterThanNode];
        break;
      default:
        node.object = object;
        break;
    }
  }
  return node;
}

- (FOTreeNode *)minNodeInTreeNode:(FOTreeNode *)node;
{
  while (node.lessThanNode) {
    node = node.lessThanNode;
  }
  return node;
}

- (FOTreeNode *)nodeByDeletingMinNodeInTreeNode:(FOTreeNode *)node;
{
  if (node.lessThanNode) {
    node.lessThanNode = [self nodeByDeletingMinNodeInTreeNode:node.lessThanNode];
  } else {
    node = node.greaterThanNode;
  }
  return node;
}

- (FOTreeNode *)removeObject:(id)object fromTreeNode:(FOTreeNode *)node;
{
  if (node != nil) {
    NSComparisonResult result = _comparator(object, node.object);
    switch (result) {
      case NSOrderedAscending:
        node.lessThanNode = [self removeObject:object fromTreeNode:node.lessThanNode];
        break;
      case NSOrderedDescending:
        node.greaterThanNode = [self removeObject:object fromTreeNode:node.greaterThanNode];
        break;
      default:
        if (node.greaterThanNode == nil) {
          node = node.lessThanNode;
        } else if (node.lessThanNode == nil) {
          node = node.greaterThanNode;
        } else {
          FOTreeNode *tempNode = node;
          node = [self minNodeInTreeNode:node.greaterThanNode];
          node.greaterThanNode = [self nodeByDeletingMinNodeInTreeNode:tempNode.greaterThanNode];
          node.lessThanNode = tempNode.lessThanNode;
        }
    }
  }
  return node;
}

- (NSUInteger)indexForObject:(id)object inTreeNode:(FOTreeNode *)node;
{
  if (node) {
    NSComparisonResult result = _comparator(object, node.object);
    switch (result) {
      case NSOrderedAscending:
        return [self indexForObject:object inTreeNode:node.lessThanNode];
      case NSOrderedDescending:
        return 1 + [node.lessThanNode count] + [self indexForObject:object inTreeNode:node.greaterThanNode];
      default:
        return [node.lessThanNode count];
    }
  }
  return 0;
}

- (FOTreeNode *)nodeWithIndex:(NSUInteger)index inTreeNode:(FOTreeNode *)node;
{
  if (node != nil) {
    NSUInteger lessThanCount = [node.lessThanNode count];
    if (lessThanCount > index) {
      return [self nodeWithIndex:index inTreeNode:node.lessThanNode];
    } else if (lessThanCount < index) {
      return [self nodeWithIndex:index - lessThanCount - 1 inTreeNode:node.greaterThanNode];
    } else {
      return node;
    }
  }
  return node;
}


#pragma mark -
#pragma mark Primitive methods for subclassing NSSet

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count;
{
  self = [self initWithCompareSelector:@selector(compare:)];
  if (self) {
    for (NSUInteger index = 0; index < count; ++index) {
      [self addObject:objects[index]];
    }
  }
  return self;
}

- (NSUInteger)count;
{
  return [_rootNode count];
}

- (id)member:(id)object;
{
  NSParameterAssert(object != nil);
  FOTreeNode *node = [self nodeWithObject:object inTreeNode:_rootNode];
  return node.object;
}

- (NSEnumerator *)objectEnumerator;
{
  __block FOTreeNode *lastNode = nil;
  __block FOTreeNode *node = _rootNode;
  return [[FOBlockEnumerator alloc] initWithEnumeratorBlock:^id{
    if (node) {
      if (node != lastNode) {
      descend:
        while (node.lessThanNode) {
          node = node.lessThanNode;
        }
        goto next;
      }
      if (node.greaterThanNode) {
        node = node.greaterThanNode;
        goto descend;
      } else {
        do {
          node = node.parentNode;
        } while (_comparator(node.object, lastNode.object) == NSOrderedAscending);
      }
    }
  next:
    lastNode = node;
    return node.object;
  }];
}

#pragma mark -
#pragma mark Primitive methods for subclassing NSMutableSet

- (void)addObject:(id)object;
{
  NSParameterAssert(object != nil);
  _rootNode = [self addObject:object toTreeNode:_rootNode];
}

- (void)removeObject:(id)object;
{
  NSParameterAssert(object);
  _rootNode = [self removeObject:object fromTreeNode:_rootNode];
}

#pragma mark -
#pragma mark FOSortedSet specific public method implementation

- (id)objectAtIndex:(NSUInteger)index;
{
  NSParameterAssert(index < [self count]);
  FOTreeNode *node = [self nodeWithIndex:index inTreeNode:_rootNode];
  return node.object;
}

- (NSUInteger)indexOfObject:(id)object;
{
  FOTreeNode *node = [self nodeWithObject:object inTreeNode:_rootNode];
  if (node) {
    return [self indexForObject:node.object inTreeNode:_rootNode];
  }
  return NSNotFound;
}

- (void)removeObjectAtIndex:(NSUInteger)index;
{
  NSParameterAssert(index < [self count]);
  id object = [self objectAtIndex:index];
  [self removeObject:object];
}

@end


@implementation FOTreeNode {
  NSUInteger _count;
}

- (void)setLessThanNode:(FOTreeNode *)node;
{
  [self invalidateCount];
  _lessThanNode = node;
  _lessThanNode.parentNode = self;
}

- (void)setGreaterThanNode:(FOTreeNode *)node;
{
  [self invalidateCount];
  _greaterThanNode = node;
  _greaterThanNode.parentNode = self;
}

- (NSUInteger)count;
{
  // Count is calculated lazily, and invalidated when any child is updated.
  if (_count == 0) {
    _count = 1;
    _count += [self.lessThanNode count];
    _count += [self.greaterThanNode count];
  }
  return _count;
}

- (void)invalidateCount;
{
  if (_count != 0) {
    _count = 0;
    [self.parentNode invalidateCount];
  }
}

- (NSString *)debugDescriptionWithIndentation:(NSUInteger)indentation prefix:(NSString *)prefix;
{
  NSMutableString *s = [NSMutableString string];
  for (int i = 0; i < indentation; ++i) {
    [s appendString:@"    "];
  }
  [s appendFormat:@"%@ %@\n", prefix, [self.object description]];
  if (self.lessThanNode) {
    [s appendString:[self.lessThanNode debugDescriptionWithIndentation:indentation + 1 prefix:@"-"]];
  }
  if (self.greaterThanNode) {
    [s appendString:[self.greaterThanNode debugDescriptionWithIndentation:indentation + 1 prefix:@"+"]];
  }
  return [s copy];
}

- (NSString *)debugDescription;
{
  return [self debugDescriptionWithIndentation:0 prefix:@"*"];
}

@end
