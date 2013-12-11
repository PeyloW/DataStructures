//
//  DataStructuresTests.m
//  DataStructuresTests
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DataStructures.h"

@interface DataStructuresTests : XCTestCase

@end

@implementation DataStructuresTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHashTableAddElements;
{
  FOHashTable *ht1 = [[FOHashTable alloc] initWithCapacity:4 collisionResolution:FOHashTableCollisionResolutionLinkedList];
  FOHashTable *ht2 = [[FOHashTable alloc] initWithCapacity:4 collisionResolution:FOHashTableCollisionResolutionOpenAddressing];
  [ht1 setObject:@1 forKey:@"A"];
  [ht2 setObject:@1 forKey:@"A"];
  XCTAssertTrue([ht1 count] == 1, @"Count is 1");
  XCTAssertTrue([ht2 count] == 1, @"Count is 1");

  [ht1 setObject:@2 forKey:@"A"];
  [ht2 setObject:@2 forKey:@"A"];
  XCTAssertTrue([ht1 count] == 1, @"Count is 1");
  XCTAssertTrue([ht2 count] == 1, @"Count is 1");

  [ht1 setObject:@3 forKey:@"B"];
  [ht2 setObject:@3 forKey:@"B"];
  XCTAssertTrue([ht1 count] == 2, @"Count is 2");
  XCTAssertTrue([ht2 count] == 2, @"Count is 2");

  NSSet *keys1 = [NSSet setWithArray:[ht1 allKeys]];
  NSSet *keys2 = [NSSet setWithArray:[ht2 allKeys]];
  NSSet *keys3 = [NSSet setWithObjects:@"A", @"B", nil];

  XCTAssertTrue([keys1 isEqualToSet:keys3], @"Keys are valid");
  XCTAssertTrue([keys2 isEqualToSet:keys3], @"Keys are valid");

  [ht1 setObject:@4 forKey:@"C"];
  [ht2 setObject:@4 forKey:@"C"];
  [ht1 setObject:@5 forKey:@"D"];
  [ht2 setObject:@5 forKey:@"D"];
  XCTAssertTrue([ht1 count] == 4, @"Count is 4");
  XCTAssertTrue([ht2 count] == 4, @"Count is 4");

  keys1 = [NSSet setWithArray:[ht1 allKeys]];
  keys2 = [NSSet setWithArray:[ht2 allKeys]];
  keys3 = [NSSet setWithObjects:@"A", @"B", @"C", @"D", nil];
  
  [ht1 setObject:@6 forKey:@"E"];
  XCTAssertTrue([ht1 count] == 5, @"Count is 5");
  XCTAssertThrows([ht2 setObject:@6 forKey:@"E"], @"Throw when over capacity.");
}

- (void)testHashTableInitAndRemoveElements;
{
  NSMutableDictionary *d = [@{ @"A" : @1, @"B" : @2, @"C" : @3, @"D" : @4, @"E" : @1, @"F" : @4 } mutableCopy];
  FOHashTable *ht1 = [[FOHashTable alloc] initWithDictionary:d];
  FOHashTable *ht2 = [[FOHashTable alloc] initWithCapacity:[d count] collisionResolution:FOHashTableCollisionResolutionOpenAddressing];
  [ht2 addEntriesFromDictionary:d];

  XCTAssertTrue([ht1 count] == [d count], @"Count matches NSDict.");
  XCTAssertTrue([ht2 count] == [d count], @"Count matches NSDict.");

  NSSet *keys1 = [ht1 keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
    return [obj isEqual:@4];
  }];
  NSSet *keys2 = [ht2 keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
    return [obj isEqual:@4];
  }];
  NSSet *keys3 = [d keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
    return [obj isEqual:@4];
  }];
  XCTAssertTrue([keys1 isEqualToSet:keys3], @"Keys are valid");
  XCTAssertTrue([keys2 isEqualToSet:keys3], @"Keys are valid");
  
  [ht1 removeObjectsForKeys:[keys1 allObjects]];
  [ht2 removeObjectsForKeys:[keys2 allObjects]];
  [d removeObjectsForKeys:[keys3 allObjects]];

  XCTAssertTrue([ht1 isEqualToDictionary:d], @"HT matches NSDict.");
  XCTAssertTrue([ht2 isEqualToDictionary:d], @"HT matches NSDict.");
}


- (void)testSortedSetAddElements;
{
  NSArray *array = @[@1, @2, @3, @5];
  FOSortedSet *ss = [[FOSortedSet alloc] initWithCompareSelector:@selector(compare:)];
  
  [ss addObject:@5];
  XCTAssertTrue([ss count] == 1, @"Count is 1");
  XCTAssertTrue([ss member:@5], @"Added object is member");
  
  [ss addObject:@1];
  [ss addObject:@3];
  [ss addObject:@2];
  
  XCTAssertTrue([ss indexOfObject:@1] == 0, @"Index is 0");
  XCTAssertTrue([ss indexOfObject:@2] == 1, @"Index is 1");
  XCTAssertTrue([ss indexOfObject:@3] == 2, @"Index is 2");
  XCTAssertTrue([ss indexOfObject:@5] == 3, @"Index is 3");
  
  XCTAssertTrue([[ss objectAtIndex:0] isEqualToNumber:@1], @"Is 1");
  XCTAssertTrue([[ss objectAtIndex:1] isEqualToNumber:@2], @"Is 2");
  XCTAssertTrue([[ss objectAtIndex:2] isEqualToNumber:@3], @"Is 3");
  XCTAssertTrue([[ss objectAtIndex:3] isEqualToNumber:@5], @"Is 4");
  
  [ss addObject:@3];
  XCTAssertTrue([ss count] == 4, @"Count is still 4");
  
  XCTAssertTrue([[ss allObjects] isEqualToArray:array], @"Order is correct");

  NSEnumerator *enuerator = [ss objectEnumerator];
  NSUInteger index = 0;
  id object;
  while (object = [enuerator nextObject]) {
    XCTAssertTrue([object isEqual:array[index]], @"Object matches");
    ++index;
  }
}

- (void)testSortedSetInitAndRemove;
{
  NSArray *array = @[@1, @2, @3, @5, @7, @125];
  NSMutableSet *set = [NSMutableSet setWithArray:array];
  FOSortedSet *ss = [[FOSortedSet alloc] initWithSet:set];
  
  XCTAssertTrue([[ss allObjects] isEqualToArray:array], @"SS order mathes array");
  
  XCTAssertTrue([ss isEqualToSet: set], @"SS Matches NSSet");

  [ss removeObject:@3];
  [set removeObject:@3];
  XCTAssertTrue([ss isEqualToSet: set], @"SS Matches NSSet");

  [ss removeObjectAtIndex:4];
  [ss removeObjectAtIndex:3];
  [set removeObject:@7];
  [set removeObject:@125];
  
  XCTAssertTrue([ss isEqualToSet: set], @"SS Matches NSSet");
}

- (void)testSparseArrayAddAndRemoveElements;
{
  FOSparseArray *sa = [[FOSparseArray alloc] initWithObjects:(id[]){@"A", @"B", @"C"}
                                                   atIndexes:(NSUInteger[]){1, 3, 4}
                                                       count:3];
  XCTAssertTrue([sa count] == 3, @"Count is 3");
  XCTAssertTrue([[sa objectAtIndex:1] isEqual:@"A"], @"Is A");
  XCTAssertNil([sa objectAtIndex:2], @"Is nil");
  XCTAssertTrue([[sa objectAtIndex:3] isEqual:@"B"], @"Is B");
  XCTAssertTrue([[sa objectAtIndex:4] isEqual:@"C"], @"Is C");

  [sa setObject:@"D" atIndex:0];
  [sa setObject:@"E" atIndex:2];
  [sa setObject:@"F" atIndex:5];
  XCTAssertTrue([sa count] == 6, @"Count is 6");
  [sa setObject:@"G" atIndex:1];
  [sa setObject:@"H" atIndex:0];
  XCTAssertTrue([sa count] == 6, @"Count is 6");
  
  NSArray *array = @[@"H", @"G", @"E", @"B", @"C", @"F"];
  [sa enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSUInteger otherIdx = [array indexOfObject:obj];
    XCTAssertTrue(otherIdx == idx, @"Indexes matches");
    XCTAssertTrue([obj isEqual:array[idx]], @"Objects matches");
  }];
  
  [sa removeObjectAtIndex:0];
  [sa removeObjectAtIndex:5];
  [sa removeObjectAtIndex:3];
  XCTAssertTrue([sa count] == 3, @"Count is 3");
}


@end
