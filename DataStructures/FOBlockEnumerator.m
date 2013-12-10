//
//  FOBlockEnumerator.m
//  DataStructures
//
//  Created by Fredrik Olsson on 10/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import "FOBlockEnumerator.h"

@implementation FOBlockEnumerator {
  __strong id(^_enumeratorBlock)();
}

- (instancetype)initWithEnumeratorBlock:(id(^)())enumeratorBlock;
{
  NSParameterAssert(enumeratorBlock != NULL);
  self = [self init];
  if (self) {
    _enumeratorBlock = [enumeratorBlock copy];
  }
  return self;
}

- (id)nextObject;
{
  return _enumeratorBlock();
}


@end
