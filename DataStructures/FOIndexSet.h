//
//  FOIndexSet.h
//  DataStructures
//
//  Created by Fredrik Olsson on 16/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * The documentation for NSIndexSet explicit states no subclassing.
 * So this is a stand alone duplicate of a subset of NSIndexSet.
 */
@interface FOIndexSet : NSObject <NSCopying, NSMutableCopying>

- (instancetype)initWithIndex:(NSUInteger)index;
- (instancetype)initWithIndexesInRange:(NSRange)range;
- (instancetype)initWithIndexSet:(FOIndexSet *)indexSet;

- (NSUInteger)count;

- (BOOL)containsIndex:(NSUInteger)index;
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger idx, BOOL *stop))block;

- (NSUInteger)firstIndex;
- (NSUInteger)lastIndex;
- (NSUInteger)indexLessThanIndex:(NSUInteger)index;
- (NSUInteger)indexLessThanOrEqualToIndex:(NSUInteger)index;
- (NSUInteger)indexGreaterThanIndex:(NSUInteger)index;
- (NSUInteger)indexGreaterThanOrEqualToIndex:(NSUInteger)index;

@end

/*!
 * The documentation for NSMutableIndexSet explicit states no subclassing.
 * So this is a stand alone duplicate of a subset of NSMutableIndexSet.
 */
@interface FOMutableIndexSet : FOIndexSet

- (void)addIndex:(NSUInteger)index;
- (void)addIndexesInRange:(NSRange)range;
- (void)addIndexes:(FOIndexSet *)indexSet;

- (void)removeAllIndexes;
- (void)removeIndex:(NSUInteger)index;
- (void)removeIndexesInRange:(NSRange)range;
- (void)removeIndexes:(FOIndexSet *)indexSet;

@end