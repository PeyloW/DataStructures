//
//  FOSparseArray.m
//  DataStructures
//
//  Created by Fredrik Olsson on 11/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "FOSparseArray.h"
#import "FOSortedSet.h"
#import "FOBlockEnumerator.h"

@interface FOIndexedObject : NSObject
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) id object;
+ (instancetype)indexedObjectWithObject:(id)object index:(NSUInteger)index;
@end


/*
 * The sparse array is implemented with a backing sorted set, where each object in the sorted set
 * ins an object/index pair that is sorted, and uniqued, by the index.
 */
@implementation FOSparseArray {
  FOSortedSet *_sortedSet;
}

- (instancetype)init;
{
  return [self initWithObjects:NULL atIndexes:NULL count:0];
}

- (instancetype)initWithObjects:(const id [])objects atIndexes:(const NSUInteger [])indexes count:(NSUInteger)count;
{
  self = [super init];
  if (self) {
    _sortedSet = [[FOSortedSet alloc] initWithComparator:^NSComparisonResult(FOIndexedObject *obj1, FOIndexedObject *obj2) {
      if (obj1.index < obj2.index) {
        return NSOrderedAscending;
      } else if (obj1.index > obj2.index) {
        return NSOrderedDescending;
      } else {
        return NSOrderedSame;
      }
    }];
    for (int index = 0; index < count; ++index) {
      [self setObject:objects[index] atIndex:indexes[index]];
    }
  }
  return self;
}

- (NSUInteger)count;
{
  return [_sortedSet count];
}

- (NSIndexSet *)occupiedIndexes;
{
  NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
  for (FOIndexedObject *indexedObject in _sortedSet) {
    [indexSet addIndex:indexedObject.index];
  }
  return [indexSet copy];
}

- (id)objectAtIndex:(NSUInteger)index;
{
  FOIndexedObject *indexedObject = [FOIndexedObject indexedObjectWithObject:[NSNull null] index:index];
  // Trust the contract of member: to return the instance in the set, not the object to test if they are equal.
  indexedObject = [_sortedSet member:indexedObject];
  return indexedObject.object;
}

- (void)setObject:(id)object atIndex:(NSUInteger)index;
{
  FOIndexedObject *indexedObject = [FOIndexedObject indexedObjectWithObject:object index:index];
  [_sortedSet addObject:indexedObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index;
{
  FOIndexedObject *indexedObject = [FOIndexedObject indexedObjectWithObject:[NSNull null] index:index];
  [_sortedSet removeObject:indexedObject];
}

- (NSEnumerator *)objectEnumerator;
{
  NSEnumerator *sortedSetEnumerator = [_sortedSet objectEnumerator];
  return [[FOBlockEnumerator alloc] initWithEnumeratorBlock:^id{
    FOIndexedObject *indexedObject = [sortedSetEnumerator nextObject];
    return indexedObject.object;
  }];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
{
  BOOL stop = NO;
  for (FOIndexedObject *indexedObject in _sortedSet) {
    block(indexedObject.object, indexedObject.index, &stop);
    if (stop) {
      break;
    }
  }
}

@end


@implementation FOIndexedObject
+ (instancetype)indexedObjectWithObject:(id)object index:(NSUInteger)index;
{
  NSParameterAssert(object != nil);
  FOIndexedObject *indexedObject = [[self alloc] init];
  indexedObject.index = index;
  indexedObject.object = object;
  return indexedObject;
}

- (NSString *)description;
{
  return [NSString stringWithFormat:@"%@ %u : %@", [super description], self.index, self.object];
}

@end
