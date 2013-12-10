//
//  FOSortedSet.h
//  DataStructures
//
//  Created by Fredrik Olsson on 10/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * FOSortedSet manages a set of objects that is guarantied to be sorted in ascending order.
 *
 * Sorted sets created by any of the initializers from superclasses will use
 * the compare: selector as the default comparison selector.
 */
@interface FOSortedSet : NSMutableSet

/*!
 * Return a sorted set, initialized to sort objects using a comparator block.
 * This is the designated initializer for FOSortedSet.
 *
 * @param comparator A comparator block used to compare objects in set.
 * @result A sorted set.
 */
- (instancetype)initWithComparator:(NSComparator)comparator;


/*!
 * Return a sorted set, initialized to sort objects using an array of NSSortDescriptors.
 *
 * @param sortDescriptors An array of sort descriptors used to compare objects in set.
 * @result A sorted set.
 */
- (instancetype)initWithSortDescriptors:(NSArray *)sortDescriptors;

/*!
 * Return a sorted set, initialized to sort objects using a comparison method specified by a selector.
 *
 * @param compareSelector A compare selector for a method returning NSComparisonResult.
 * @result A sorted set.
 */
- (instancetype)initWithCompareSelector:(SEL)compareSelector;

/*!
 * Returns the object at the specified index of the set.
 *
 * @param index The index of the object to retrieve.
 * @result The object located at index.
 */
- (id)objectAtIndex:(NSUInteger)index;

/*!
 * Returns the index of the specified object.
 *
 * @param object The object.
 */
- (NSUInteger)indexOfObject:(id)object;

/*!
 * Remove the object at the specified index of the set.
 *
 * @param index The index of the object to remove.
 */
- (void)removeObjectAtIndex:(NSUInteger)index;

@end
