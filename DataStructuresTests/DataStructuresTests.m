//
//  DataStructuresTests.m
//  DataStructuresTests
//
//  Created by Fredrik Olsson on 09/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOHashTable.h"


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

@end
