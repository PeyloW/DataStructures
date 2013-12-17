//
//  FOIndexSet.m
//  DataStructures
//
//  Created by Fredrik Olsson on 16/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "FOIndexSet.h"

#define FOPrimitiveArrayType NSRange
#include "FOPrimitiveArray.h"

/*
 * The FOIndexSet is implemented as a primitive array of NSRanges. Any method or function that adds 
 * or removes indexes must merge or split ranges to guarantee that all the ranges in the array
 * have gaps between, overlapping and adjecent ranges MUST be merged.
 *
 * For clarity "position" is the position/index of a range in the primitive array, and index is always
 * an index in the index set.
 *
 * FOArrayPositionForIndex do much of the grunt work by finding the position where an index is found,
 * or where to insert if not found.
 */
static inline NSUInteger FOArrayPositionForIndex(FOPrimitiveArray *array, NSUInteger index) {
  NSUInteger count = FOPrimitiveArrayGetCount(array);
  NSUInteger minPosition = 0, maxPosition = count;
  NSUInteger position;
  
  for (position = maxPosition / 2; maxPosition != minPosition; position = (maxPosition + minPosition) / 2) {
    NSRange range = FOPrimitiveArrayGetItemAtIndex(array, position);
    if (index < range.location) {
      maxPosition = position;
    } else if (index > NSMaxRange(range)) {
      minPosition = position + 1;
    } else {
      break;
    }
  }
  while (position < count && index >= NSMaxRange(FOPrimitiveArrayGetItemAtIndex(array, position))) {
    position++;
  }
  return position;
}


@implementation FOIndexSet {
@protected
  NSUInteger _count;
  FOPrimitiveArray *_array;
}

#pragma mark -
#pragma mark Life time implementation

- (instancetype)initWithIndex:(NSUInteger)index;
{
  NSParameterAssert(index != NSNotFound);
  NSRange range = NSMakeRange(index, 1);
  return [self initWithIndexesInRange:range];
}

- (instancetype)initWithIndexesInRange:(NSRange)range;
{
  NSParameterAssert(range.length > 0);
  self = [super init];
  if (self) {
    _count = range.length;
    _array = FOPrimitiveArrayCreateWithCapacity(1);
    FOPrimitiveArrayAddItem(_array, range);
  }
  return self;
}

- (instancetype)initWithIndexSet:(FOIndexSet *)indexSet;
{
  NSParameterAssert(indexSet != nil);
  FOPrimitiveArray *_other = indexSet->_array;
  if (_other) {
    self = [super init];
    if (self) {
      _count = NSNotFound;
      if (indexSet->_array != NULL) {
        NSUInteger count = FOPrimitiveArrayGetCount(_other);
        _array = FOPrimitiveArrayCreateWithCapacity(count);
        for (NSUInteger position = 0; position < count; ++position) {
          FOPrimitiveArrayAddItem(_array, FOPrimitiveArrayGetItemAtIndex(_other, position));
        }
      }
    }
    return self;
  } else {
    return [self init];
  }
}

- (void)dealloc;
{
  if (_array) {
    FOPrimitiveArrayFree(_array);
    _array = NULL;
  }
}

#pragma mark -
#pragma mark Copying and mutable copying implementation

- (id)copyWithZone:(NSZone *)zone;
{
  if ([self class] == [FOIndexSet class]) {
    return self;
  } else {
    return [[FOIndexSet allocWithZone:zone] initWithIndexSet:self];
  }
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
  return [[FOMutableIndexSet allocWithZone:zone] initWithIndexSet:self];
}

#pragma mark -
#pragma mark Public API implementation

- (NSUInteger)count;
{
  // Lazily calculate if needed, mutating methods must set to NSNotFound.
  if (_count == NSNotFound) {
    if (_array) {
      _count = 0;
      for (NSUInteger index = 0; index < FOPrimitiveArrayGetCount(_array); ++index) {
        _count += FOPrimitiveArrayGetItemAtIndex(_array, index).length;
      }
    }
  }
  return _count;
}

- (BOOL)containsIndex:(NSUInteger)index;
{
  if (_array) {
    NSUInteger count = FOPrimitiveArrayGetCount(_array);
    NSUInteger position = FOArrayPositionForIndex(_array, index);
    if (position < count) {
      NSRange range = FOPrimitiveArrayGetItemAtIndex(_array, position);
      return NSLocationInRange(index, range);
    }
  }
  return NO;
}

- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger idx, BOOL *stop))block;
{
  if (_array) {
    BOOL stop = NO;
    for (NSUInteger index = 0; index < FOPrimitiveArrayGetCount(_array); ++index) {
      NSRange range = FOPrimitiveArrayGetItemAtIndex(_array, index);
      for (NSUInteger index = 0; index < range.length; ++index) {
        block(index, &stop);
        if (stop) {
          return;
        }
      }
    }
  }
}

- (NSUInteger)firstIndex;
{
  if (_array) {
    NSRange range = FOPrimitiveArrayGetItemAtIndex(_array, 0);
    return range.location;
  }
  return NSNotFound;
}

- (NSUInteger)lastIndex;
{
  if (_array) {
    NSRange range = FOPrimitiveArrayGetItemAtIndex(_array, FOPrimitiveArrayGetCount(_array) - 1);
    return NSMaxRange(range);
  }
  return NSNotFound;
}

- (NSUInteger)indexLessThanIndex:(NSUInteger)index;
{
  if (_array && index > 0) {
    --index;
    NSUInteger count = FOPrimitiveArrayGetCount(_array);
    NSUInteger position = FOArrayPositionForIndex(_array, index);
    
    if (position < count) {
      NSRange range = FOPrimitiveArrayGetItemAtIndex(_array, position);
      if (NSLocationInRange(index, range)) {
        return index;
      }
      if (position-- == 0) {
        return NSNotFound;
      }
      range = FOPrimitiveArrayGetItemAtIndex(_array, position);
      return NSMaxRange(range) - 1;
    }
  }
  return NSNotFound;
}

- (NSUInteger)indexLessThanOrEqualToIndex:(NSUInteger)index;
{
  if ([self containsIndex:index]) {
    return index;
  } else if (index > 0) {
    return [self indexLessThanIndex:index];
  }
  return NSNotFound;
}

- (NSUInteger)indexGreaterThanIndex:(NSUInteger)index;
{
  if (_array != NULL && index < NSNotFound) {
    ++index;
    NSUInteger count = FOPrimitiveArrayGetCount(_array);
    NSUInteger position = FOArrayPositionForIndex(_array, index);
    
    if (position < count) {
      NSRange range = FOPrimitiveArrayGetItemAtIndex(_array, position);
      if (NSLocationInRange(index, range)) {
        return index;
      }
      return range.location;
    }
  }
  return NSNotFound;
}

- (NSUInteger)indexGreaterThanOrEqualToIndex:(NSUInteger)index;
{
  if ([self containsIndex:index]) {
    return index;
  } else {
    return [self indexGreaterThanIndex:index];
  }
}

@end


@implementation FOMutableIndexSet

- (void)addIndex:(NSUInteger)index;
{
  NSRange range = NSMakeRange(index, 1);
  [self addIndexesInRange:range];
}

- (void)addIndexesInRange:(NSRange)range;
{
  if (range.length > 0) {
    _count = NSNotFound;
    if (_array == NULL) {
      _array = FOPrimitiveArrayCreateWithCapacity(8);
    }
    
    NSUInteger count = FOPrimitiveArrayGetCount(_array);
    NSUInteger position = FOArrayPositionForIndex(_array, range.location);
    if (position >= count) {
      FOPrimitiveArrayAddItem(_array, range);
    } else {
      NSRange existingRange = FOPrimitiveArrayGetItemAtIndex(_array, position);
      
      if (NSLocationInRange(range.location, existingRange)) {
        ++position;
      }
      FOPrimitiveArrayInsertItemAtIndex(_array, range, position);
    }
    
    // Merge with previous ranges if needed.
    while (position > 0) {
      NSRange prevRange = FOPrimitiveArrayGetItemAtIndex(_array, position - 1);
      if (NSMaxRange(prevRange) < range.location) {
        break;
      }
      if (NSMaxRange(prevRange) >= NSMaxRange(range)) {
        FOPrimitiveArrayRemoveItemAtIndex(_array, position);
        --position;
      } else {
        prevRange.length += (NSMaxRange(range) - NSMaxRange(prevRange));
        FOPrimitiveArrayRemoveItemAtIndex(_array, position);
        --position;
        FOPrimitiveArraySetItemAtIndex(_array, prevRange, position);
      }
    }
    
    // Merge with next ranges if needed.
    while (position + 1 < FOPrimitiveArrayGetCount(_array)) {
      NSRange nextRange = FOPrimitiveArrayGetItemAtIndex(_array, position + 1);
      if (NSMaxRange(range) < nextRange.location) {
        break;
      }
      FOPrimitiveArrayRemoveItemAtIndex(_array, position + 1);
      if (NSMaxRange(nextRange) > NSMaxRange(range)) {
        NSUInteger offset = NSMaxRange(nextRange) - NSMaxRange(range);
        nextRange = FOPrimitiveArrayGetItemAtIndex(_array, position);
        nextRange.length += offset;
        FOPrimitiveArraySetItemAtIndex(_array, nextRange, position);
      }
    }
  }
}

- (void)addIndexes:(FOIndexSet *)indexSet;
{
  if (indexSet->_array != NULL) {
    for (NSUInteger position = 0; position < FOPrimitiveArrayGetCount(indexSet->_array); ++position) {
      [self addIndexesInRange:FOPrimitiveArrayGetItemAtIndex(indexSet->_array, position)];
    }
  }
}

- (void)removeAllIndexes;
{
  if (_array != NULL) {
    _count = 0;
    FOPrimitiveArrayRemoveAllItems(_array);
  }
}

- (void)removeIndex:(NSUInteger)index;
{
  if (_array != NULL) {
    NSRange range = NSMakeRange(index, 1);
    [self removeIndexesInRange:range];
  }
}

- (void)removeIndexesInRange:(NSRange)range;
{
  if (_array != NULL || range.length == 0) {
    _count = NSNotFound;
    NSUInteger count = FOPrimitiveArrayGetCount(_array);
    NSUInteger position = FOArrayPositionForIndex(_array, range.location);
    if (position < count) {
      NSRange existingRange = FOPrimitiveArrayGetItemAtIndex(_array, position);
      if (existingRange.location <= range.location) {
        if (existingRange.location == range.location) {
          if (NSMaxRange(existingRange) <= NSMaxRange(range)) {
            // Existing range is completely inside range to remove.
            FOPrimitiveArrayRemoveItemAtIndex(_array, position);
          } else {
            // Range to remove is completely inside existing range.
            existingRange.location += range.length;
            existingRange.length -= range.length;
            FOPrimitiveArraySetItemAtIndex(_array, existingRange, position);
            ++position;
          }
        } else {
          if (NSMaxRange(existingRange) <= NSMaxRange(range)) {
            // Range to remove overlaps end of existing range (potentially next existing range too).
            existingRange.length = range.location - existingRange.location;
            FOPrimitiveArraySetItemAtIndex(_array, existingRange, position);
            ++position;
          } else {
            NSRange next = existingRange;
            // Range to remove is completely inside existing range.
            next.location = NSMaxRange(range);
            next.length = NSMaxRange(existingRange) - next.location;
            existingRange.length = range.location - existingRange.location;
            FOPrimitiveArraySetItemAtIndex(_array, existingRange, position);
            FOPrimitiveArrayInsertItemAtIndex(_array, next, position + 1);
            position += 2;
          }
        }
      }
      
      // Remove from next ranges if needed.
      while (position < FOPrimitiveArrayGetCount(_array)) {
        NSRange nextRange = FOPrimitiveArrayGetItemAtIndex(_array, position);
        
        if (NSMaxRange(nextRange) <= NSMaxRange(range)) {
          // Next range completely inside range to remove.
          FOPrimitiveArrayRemoveItemAtIndex(_array, position);
        } else {
          if (nextRange.location < NSMaxRange(range)) {
            // Range to remove overlaps start of next range.
            nextRange.length = NSMaxRange(nextRange) - NSMaxRange(range);
            nextRange.location = NSMaxRange(range);
            FOPrimitiveArraySetItemAtIndex(_array, nextRange, position);
          }
          break;
        }
      }
    }
  }
}

- (void)removeIndexes:(FOIndexSet *)indexSet;
{
  if (_array != NULL && indexSet->_array != NULL) {
    for (NSUInteger position = 0; position < FOPrimitiveArrayGetCount(indexSet->_array); ++position) {
      [self removeIndexesInRange:FOPrimitiveArrayGetItemAtIndex(indexSet->_array, position)];
    }
  }
}

@end