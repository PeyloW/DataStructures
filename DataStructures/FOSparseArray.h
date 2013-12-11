//
//  FOSparseArray.h
//  DataStructures
//
//  Created by Fredrik Olsson on 11/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FOSparseArray : NSObject

/*!
 * Returns a sparse array, initialized with objects at indexes.
 * This is the designated initializer for FOSparseArray.
 *
 * @param objects A C array of values for the new sparse array.
 * @param indexes A C array of indexes for the new sparse array.
 * @result A fixed array.
 */
- (instancetype)initWithObjects:(const id [])objects atIndexes:(const NSUInteger [])indexes count:(NSUInteger)count;

/*!
 * Return the number of objects currently in the sparse array.
 *
 * @result The number of objects currently in the sparse array.
 */
- (NSUInteger)count;

/*!
 * Return an index set with the indexes currently occupied by objects in the sparse array.
 *
 * @result An index set with the indexes currently occupied by objects in the sparse array.
 */
- (NSIndexSet *)occupiedIndexes;

/*!
 * Returns the object located at the specified index, or nil if no object occupies the specified index.
 *
 * @param index An index within the capacity of the fixed array.
 * @result The object located at index, or nil if index is not occupied.
 */
- (id)objectAtIndex:(NSUInteger)index;

/*!
 * Set or replace the object at the speciefied index.
 *
 * @param object An object to set.
 * @param index The index.
 */
- (void)setObject:(id)object atIndex:(NSUInteger)index;

/*!
 * Removes the object at index.
 *
 * @param index The index from which to remove the object in the array.
 */
- (void)removeObjectAtIndex:(NSUInteger)index;

/*!
 * Returns an enumerator object that lets you access each object in the array.
 *
 * @result An enumerator object that lets you access each object in the array.
 *
 */
- (NSEnumerator *)objectEnumerator;


/*!
 * Executes a given block using each object in the array.
 *
 * @param The block to apply to elements in the array.
 */
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
