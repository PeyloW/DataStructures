//
//  FOBlockEnumerator.h
//  DataStructures
//
//  Created by Fredrik Olsson on 10/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Helper class for implementing enumerators using a block.
 */
@interface FOBlockEnumerator : NSEnumerator

/*!
 * Return an enumerator, initialized with a block responsible for implementing the nextObject method.
 *
 * @param nextEnumerator A block implementing the functionality of the nextObject method.
 * @result An object enumetaror.
 *
 * @see -[NSEnumerator nextObject]
 */
- (instancetype)initWithEnumeratorBlock:(id(^)())nextEnumerator;

@end
