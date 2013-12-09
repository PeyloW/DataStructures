//
//  FOSparseArray.m
//  DataStructures
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "FOSparseArray.h"

/*
 * The implementation of FOSparseArray uses a fixed array of objects.
 * This gives best access times for both adding and removing objects,
 * at the cost of a memory usage overhead.
 * This overhead is unimportant when the fill-rate is high, and/or the
 * maximum capacity is low.
 * Could use a linked list implementation if the maximum capacity is
 * huge and the fill-rate is low.
 */
@implementation FOSparseArray {
  NSMutableIndexSet *_occupieIndexes;
  NSUInteger _capacity;
  __strong id *_objects;
}

- (instancetype)init;
{
  return [self initWithCapacity:0];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity;
{
  self = [super init];
  if (self) {
    _occupieIndexes = [[NSMutableIndexSet alloc] init];
    _capacity = capacity;
    _objects = (__strong id*)calloc(capacity, sizeof(id));
  }
  return self;
}

- (void)dealloc;
{
  [_occupieIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
    _objects[index] = nil;
  }];
  free(_objects);
}

- (NSUInteger)count;
{
  return [_occupieIndexes count];
}

- (NSUInteger)capacity;
{
  return _capacity;
}

- (NSIndexSet *)occupiedIndexes;
{
  return [_occupieIndexes copy];
}

- (id)objectAtIndex:(NSUInteger)index;
{
  NSParameterAssert(index < _capacity);
  return _objects[index];
}

- (void)setObject:(id)object atIndex:(NSUInteger)index;
{
  NSParameterAssert(index < _capacity);
  if (object) {
    [_occupieIndexes addIndex:index];
  } else {
    [_occupieIndexes removeIndex:index];
  }
  _objects[index] = object;
}

@end
