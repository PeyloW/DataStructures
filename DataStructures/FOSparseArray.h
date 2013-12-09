//
//  FOSparseArray.h
//  DataStructures
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * FOSparseArray manages an array of objects, with a fixed maximum capacity, where elements may be nil.
 *
 * The sparse array is intentionally not a subclass of NSArray or NSMutableArray. Doing so would breaks
 * the contract of NSArray that any element at index less than count is a valid object.
 */
@interface FOSparseArray : NSObject

/*!
 * Returns a sparse array, initialized to hold a maximum capacity.
 *
 * @param capacity The sparse array's maximum capacity.
 * @result A sparse array.
 */
- (instancetype)initWithCapacity:(NSUInteger)capacity;

/*!
 * Return the number of objects currently in the sparse array.
 *
 * @result The number of objects currently in the sparse array.
 */
- (NSUInteger)count;

/*!
 * Return the maximum capacity of the sparse array.
 *
 * @result The maximum capacity of the sparse array.
 */
- (NSUInteger)capacity;

/*!
 * Return an index set with the indexes currently occupied by objects in the sparse array.
 *
 * @result An index set with the indexes currently occupied by objects in the sparse array.
 */
- (NSIndexSet *)occupiedIndexes;

/*!
 * Returns the object located at the specified index, or nil of no object occupies the specified index.
 *
 * @param index An index within the capacity of the sparse array.
 * @result The object located at index, or nil of index is not occupied.
 */
- (id)objectAtIndex:(NSUInteger)index;

/*!
 * Set or remove the object at the speciefied index.
 *
 * @param object An object to set, or nil to remove an object from the sparse array.
 * @param index An index within the capacity of the sparse array.
 */
- (void)setObject:(id)object atIndex:(NSUInteger)index;

@end
