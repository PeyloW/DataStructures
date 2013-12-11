//
//  FOFixedArray.h
//  DataStructures
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * FOFixedArray manages an array of objects, with a fixed maximum capacity, where elements may be nil.
 *
 * The fixed array is intentionally not a subclass of NSArray or NSMutableArray. Doing so would breaks
 * the contract of NSArray that any element at index less than count is a valid object.
 */
@interface FOFixedArray : NSObject

/*!
 * Returns a fixed array, initialized to hold a maximum capacity.
 * This is the designated initializer for FOFixedArray.
 *
 * @param capacity The fixed array's maximum capacity.
 * @result A fixed array.
 */
- (instancetype)initWithCapacity:(NSUInteger)capacity;

/*!
 * Return the number of objects currently in the fixed array.
 *
 * @result The number of objects currently in the fixed array.
 */
- (NSUInteger)count;

/*!
 * Return the maximum capacity of the fixed array.
 *
 * @result The maximum capacity of the fixed array.
 */
- (NSUInteger)capacity;

/*!
 * Return an index set with the indexes currently occupied by objects in the fixed array.
 *
 * @result An index set with the indexes currently occupied by objects in the fixed array.
 */
- (NSIndexSet *)occupiedIndexes;

/*!
 * Returns the object located at the specified index, or nil of no object occupies the specified index.
 *
 * @param index An index within the capacity of the fixed array.
 * @result The object located at index, or nil of index is not occupied.
 */
- (id)objectAtIndex:(NSUInteger)index;

/*!
 * Set or remove the object at the speciefied index.
 *
 * @param object An object to set, or nil to remove an object from the fixed array.
 * @param index An index within the capacity of the fixed array.
 */
- (void)setObject:(id)object atIndex:(NSUInteger)index;

@end
