//
//  FOHashTable.m
//  DataStructures
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "FOHashTable.h"
#import "FOFixedArray.h"
#import "FOBlockEnumerator.h"

#pragma mark -
#pragma mark Private helper classes

/*
 * Key/Value pair used with open addressing policy.
 */
@interface FOKeyValuePair : NSObject
@property (nonatomic, copy) id key;
@property (nonatomic, strong) id value;
@end

/*
 * Linked key/value pair used with linked list policy.
 */
@interface FOLinkedKeyValuePair : FOKeyValuePair
@property (nonatomic, strong) FOLinkedKeyValuePair *nextKeyValuePair;
@property (nonatomic, weak) FOLinkedKeyValuePair *previousKeyValuePair;
@end

// A marker object used with open addressing policy to mark deleted key/value pairs.
static id FOOpenAddressDeletedMarker;


#pragma mark -

@implementation FOHashTable {
  FOHashTableCollisionResolution _resolution;
  NSUInteger _count;
  FOFixedArray *_buckets;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity collisionResolution:(FOHashTableCollisionResolution)resolution;
{
  self = [self init];
  if (self) {
    _resolution = resolution;
    if (resolution == FOHashTableCollisionResolutionLinkedList) {
      // Use only haf as many buckets as the capacity with linked list policy.
      capacity = MAX(1, capacity / 2);
    } else {
      // Setup the deleted marker on first init of a hash tabale with open addressing policy.
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
        FOOpenAddressDeletedMarker = [NSNull null];
      });
    }
    _buckets = [[FOFixedArray alloc] initWithCapacity:capacity];
  }
  return self;
}

#pragma mark -
#pragma mark Private helper methods

- (NSUInteger)bucketIndexForKey:(id)key;
{
  return [key hash] % [_buckets capacity];
}

- (FOLinkedKeyValuePair *)keyValuePairWithLinkedListForKey:(id)key withBucketIndex:(NSUInteger *)bucketOut;
{
  NSUInteger bucket = [self bucketIndexForKey:key];
  if (bucketOut) {
    *bucketOut = bucket;
  }
  FOLinkedKeyValuePair *keyValuePair = [_buckets objectAtIndex:bucket];
  while (keyValuePair != nil) {
    if ([keyValuePair.key isEqual:key]) {
      return keyValuePair;
    }
    keyValuePair = keyValuePair.nextKeyValuePair;
  }
  return nil;
}

- (id)keyValuePairWithOpenAddressingForKey:(id)key withBucketIndex:(NSUInteger *)bucketOut;
{
  FOKeyValuePair *keyValuePair;
  NSUInteger bucket = [self bucketIndexForKey:key];
  NSUInteger capacity = [_buckets capacity];
  for (int tries = 0; tries < capacity; ++tries) {
    keyValuePair = [_buckets objectAtIndex:bucket];
    if (keyValuePair != FOOpenAddressDeletedMarker &&
        (keyValuePair == nil || [keyValuePair.key isEqual:key])) {
      if (bucketOut) {
        *bucketOut = bucket;
      }
      return keyValuePair;
    } else {
      bucket = (bucket + 1) % capacity;
    }
  }
  if (bucketOut) {
    *bucketOut = NSNotFound;
  }
  return nil;
}

/*
 * Find an existing key/value pair for a given key. 
 *
 * Optionally return the bucket index where the key/value pair was found, or where a new
 * key/value pair should be stored.
 *
 * @param key A key.
 * @param bucketOut A bucket index where the key/value pair was found, or where to store a new pair. Or NSNotFound if a new key/value pair can not be stored due to all buckets being used with open addressing policy.
 * @result A key/value pair if found, or nil if not matching key was found.
 */
- (FOKeyValuePair *)keyValuePairForKey:(id)key withBucketIndex:(NSUInteger *)bucketOut;
{
  if (_resolution == FOHashTableCollisionResolutionLinkedList) {
    return [self keyValuePairWithLinkedListForKey:key
                                  withBucketIndex:bucketOut];
  } else {
    return [self keyValuePairWithOpenAddressingForKey:key
                                      withBucketIndex:bucketOut];
  }
}

/*
 * Add new linked key/value pair to the head of a bucket with linked list policy.
 */
- (void)addLinkedKeyValuePairWithKey:(id)key value:(id)value inBucketAtIndex:(NSUInteger)bucket;
{
  FOLinkedKeyValuePair *linkedKeyValuePair = [[FOLinkedKeyValuePair alloc] init];
  linkedKeyValuePair.key = key;
  linkedKeyValuePair.value = value;
  linkedKeyValuePair.nextKeyValuePair = [_buckets objectAtIndex:bucket];
  linkedKeyValuePair.nextKeyValuePair.previousKeyValuePair = linkedKeyValuePair;
  [_buckets setObject:linkedKeyValuePair atIndex:bucket];
}

/*
 * Add a new key/value pair to a bucket with linked list policy.
 */
- (void)addKeyValuePairWithKey:(id)key value:(id)value inBucketAtIndex:(NSUInteger)bucket;
{
  FOKeyValuePair *keyValuePair = [[FOKeyValuePair alloc] init];
  keyValuePair.key = key;
  keyValuePair.value = value;
  [_buckets setObject:keyValuePair atIndex:bucket];
}

/*
 * Remove a linked key/value pair from anywhere in the list of a bucket in linked list policy.
 */
- (void)removeLinkedKeyValuePair:(FOLinkedKeyValuePair *)linkedKeyValuePair inBucketAtIndex:(NSUInteger)bucket;
{
  linkedKeyValuePair.nextKeyValuePair.previousKeyValuePair = linkedKeyValuePair.previousKeyValuePair;
  if (linkedKeyValuePair.previousKeyValuePair) {
    linkedKeyValuePair.previousKeyValuePair.nextKeyValuePair = linkedKeyValuePair.nextKeyValuePair;
  } else {
    [_buckets setObject:linkedKeyValuePair.nextKeyValuePair atIndex:bucket];
  }
}

/*
 * Mark a key/value pair as delete in open addressing policy.
 * Simply removing the pair would give false "not in hash table" results.
 */
- (void)removeOpenAddressKeyValuePairInBucketAtIndex:(NSUInteger)bucket;
{
  [_buckets setObject:FOOpenAddressDeletedMarker atIndex:bucket];
}

#pragma mark -
#pragma mark Primitive methods for subclassing NSDictionary

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt;
{
  self = [self initWithCapacity:cnt
            collisionResolution:FOHashTableCollisionResolutionLinkedList];
  if (self) {
    for (NSUInteger index = 0; index < cnt; ++index) {
      [self setObject:objects[index] forKey:keys[index]];
    }
  }
  return self;
}

- (NSUInteger)count;
{
  return _count;
}

- (id)objectForKey:(id)key;
{
  FOKeyValuePair *keyValuePair = [self keyValuePairForKey:key
                                          withBucketIndex:NULL];
  return keyValuePair.value;
}

- (NSEnumerator *)keyEnumeratorWithLinkedList;
{
  NSIndexSet *occupiedBuckets = [_buckets occupiedIndexes];
  __block NSUInteger bucketIndex = 0;
  __block FOLinkedKeyValuePair *linkedKeyValuePair;
  return [[FOBlockEnumerator alloc] initWithEnumeratorBlock:^id{
    linkedKeyValuePair = linkedKeyValuePair.nextKeyValuePair;
    if (linkedKeyValuePair == nil) {
      bucketIndex = [occupiedBuckets indexGreaterThanOrEqualToIndex:bucketIndex];
      if (bucketIndex != NSNotFound) {
        linkedKeyValuePair = [_buckets objectAtIndex:bucketIndex];
        ++bucketIndex;
      }
    }
    return linkedKeyValuePair.key;
  }];
}

- (NSEnumerator *)keyEnumeratorWithOpenAddressing;
{
  NSIndexSet *occupiedBuckets = [_buckets occupiedIndexes];
  __block NSUInteger bucketIndex = 0;
  return [[FOBlockEnumerator alloc] initWithEnumeratorBlock:^id{
  retry:
    bucketIndex = [occupiedBuckets indexGreaterThanOrEqualToIndex:bucketIndex];
    if (bucketIndex != NSNotFound) {
      FOKeyValuePair *keyValuePair = [_buckets objectAtIndex:bucketIndex];
      ++bucketIndex;
      if (keyValuePair == FOOpenAddressDeletedMarker) {
        goto retry;
      }
      return keyValuePair.key;
    }
    return nil;
  }];
}

- (NSEnumerator *)keyEnumerator;
{
  if (_resolution == FOHashTableCollisionResolutionLinkedList) {
    return [self keyEnumeratorWithLinkedList];
  } else {
    return [self keyEnumeratorWithOpenAddressing];
  }
}


#pragma mark -
#pragma mark Primitive methods for subclassing NSDictionary

- (void)setObject:(id)object forKey:(id<NSCopying>)key;
{
  NSUInteger bucket;
  FOKeyValuePair *keyValuePair = [self keyValuePairForKey:key withBucketIndex:&bucket];
  if (keyValuePair) {
    keyValuePair.value = object;
  } else if (bucket == NSNotFound) {
    [NSException raise:NSInternalInconsistencyException
                format:@"%@ max capacity of %lu reached", NSStringFromClass([self class]), (unsigned long)[_buckets capacity]];
  } else {
    if (_resolution == FOHashTableCollisionResolutionLinkedList) {
      [self addLinkedKeyValuePairWithKey:key value:object inBucketAtIndex:bucket];
    } else {
      [self addKeyValuePairWithKey:key value:object inBucketAtIndex:bucket];
    }
    ++_count;
  }
}

- (void)removeObjectForKey:(id)key;
{
  NSUInteger bucket;
  FOKeyValuePair *keyValuePair = [self keyValuePairForKey:key withBucketIndex:&bucket];
  if (keyValuePair) {
    if (_resolution == FOHashTableCollisionResolutionLinkedList) {
      [self removeLinkedKeyValuePair:(id)keyValuePair inBucketAtIndex:bucket];
    } else {
      [self removeOpenAddressKeyValuePairInBucketAtIndex:bucket];
    }
    --_count;
  }
}

@end


#pragma mark -
#pragma mark Private helper class implementations

@implementation FOKeyValuePair
@end

@implementation FOLinkedKeyValuePair
@end
