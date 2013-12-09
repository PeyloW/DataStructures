//
//  FOHashTable.h
//  DataStructures
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Implementation for the hash tables collision resolution.
 */
typedef NS_ENUM(NSInteger, FOHashTableCollisionResolution) {
  FOHashTableCollisionResolutionLinkedList,    //! Colliding hashes use a linked list for each bucket.
  FOHashTableCollisionResolutionOpenAddressing //! Colliding hashes uses the next free bucket.
};

@interface FOHashTable : NSMutableDictionary

/*!
 * Returns a hash table, initialized with a capacity and a collision resolution policy.
 *
 * Linked list collision resulution uses a linked list of key/value pairs for each hash bucket,
 * enabling a potentially infinite number of elements.
 * Open addressing collision resolution uses only one key/value pair per hash bucket, using the
 * next free bucket on collision. The hash tables capacity is thus a hard limit to the maximum
 * number of elements.
 *
 * @param capacity The hash tables target capacity, or hard max for open addressing collision resolution.
 * @param resolution The collision resolution policy to apply.
 * @result A hash table.
 *
 */
- (instancetype)initWithCapacity:(NSUInteger)capacity collisionResolution:(FOHashTableCollisionResolution)resolution;

@end
