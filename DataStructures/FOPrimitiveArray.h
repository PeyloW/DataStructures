//
//  FOPrimitiveArray.h
//  DataStructures
//
//  Created by Fredrik Olsson on 12/12/13.
//  Copyright (c) 2013 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>


//#ifndef _FOPrimitiveArray_h
//#define _FOPrimitiveArray_h

#undef NSCParameterAssert
#define NSCParameterAssert(i)

/*!
 * The implementation file immporting FOPrimitiveArray.h must define FOPrimitiveArrayType as
 * the type of items in the primitive array _before_ including the file.
 */
#ifndef FOPrimitiveArrayType
# error "FOPrimitiveArrayType must be defined before importing FOPrimitiveArray.h"
#endif

/*!
 * If FOPrimitiveArrayType is an Obj-C class then FOPrimitiveArrayTypeReference _must_ be
 * defined before including the file as well. Define as:
 *   0 - For an array of primitive C or C++ types.
 *   1 - For strong references to Obj-C class.
 *   2 - For weak references to Obj-C class.
 */
#ifndef FOPrimitiveArrayTypeReference
# define FOPrimitiveArrayTypeReference 0
#endif


/*!
 * FOPrimitiveArray struct type.
 * The actual type depends on what FOPrimitiveArrayType is defined as when FOPrimitiveArray.h
 * is included.
 * This structs content is to be concidered private, and only to be accessed using the
 * functions defined in this header.
 */
typedef struct {
  NSUInteger count, capacity;
#if (FOPrimitiveArrayTypeReference == 0)
  FOPrimitiveArrayType *items;
#elif (FOPrimitiveArrayTypeReference == 1)
  __strong FOPrimitiveArrayType *items;
#elif (FOPrimitiveArrayTypeReference == 2)
  __weak FOPrimitiveArrayType *items;
#else
# error "Unsupported FOPrimitiveArrayTypeReference"
#endif
} FOPrimitiveArray;

/*!
 * Grow the primitive arrays capacity to a new capacity.
 * Optionaly leaving a gap at a defined index for faster insertions.
 * There is no reason to call this function manually, it will be called as needed.
 *
 * @param array The primitive array.
 * @param newCapacity The new capacity.
 * @param gapIndex An index in the valid range of the array to leave gap at, or NSNotFound to leave no gap.
 */
static inline void FOPrimitiveArrayGrowToCapacity(FOPrimitiveArray *array, NSUInteger newCapacity, NSUInteger gapIndex);


/*!
 * Create and initializa new primitive array with an initial capacity.
 *
 * @param capacity The initial capacity.
 * @result A new primitive array.
 */
static inline FOPrimitiveArray *FOPrimitiveArrayCreateWithCapacity(NSUInteger capacity) {
  NSCParameterAssert(capacity > 0);
  FOPrimitiveArray *array = calloc(1, sizeof(FOPrimitiveArray));
  FOPrimitiveArrayGrowToCapacity(array, capacity, NSNotFound);
  return array;
}


/*!
 * Free a primitive array.
 *
 * @param array The primitive array.
 */
static inline void FOPrimitiveArrayFree(FOPrimitiveArray *array) {
  NSCParameterAssert(array != NULL);
#if (FOPrimitiveArrayTypeReference != 0)
  for (NSUInteger i = 0; i < array->count; ++i) {
    array->items[i] = nil;
  }
#endif
  free(array->items);
  free(array);
}

/*!
 * Get the count of items from a primitive array.
 *
 * @param array The primitive array.
 * @result The count of items.
 */
static inline NSUInteger FOPrimitiveArrayGetCount(FOPrimitiveArray *array) {
  NSCParameterAssert(array != NULL);
  return array->count;
}

/*!
 * Get the item at an index from a primitive array.
 *
 * @param array The primitive array.
 * @param index The index of the item to get.
 * @result The item.
 */
static inline FOPrimitiveArrayType FOPrimitiveArrayGetItemAtIndex(FOPrimitiveArray *array, NSUInteger index) {
  NSCParameterAssert(index < array->count);
  return array->items[index];
}

/*!
 * Add an item at the end of a primitive array.
 *
 * @param array The primitive array.
 * @param item The item.
 */
static inline void FOPrimitiveArrayAddItem(FOPrimitiveArray *array, FOPrimitiveArrayType item) {
  NSCParameterAssert(array != NULL);
  if (array->capacity == array->count) {
    FOPrimitiveArrayGrowToCapacity(array, array->capacity * 2, NSNotFound);
  }
  array->items[array->count++] = item;
}

/*!
 * Set an item at an index of a primitive array.
 *
 * @param array The primitive array.
 * @param item The item.
 * @param index The index of the item to set.
 */
static inline void FOPrimitiveArraySetItemAtIndex(FOPrimitiveArray *array, FOPrimitiveArrayType item, NSUInteger index) {
  NSCParameterAssert(array != NULL);
  NSCParameterAssert(index < array->count);
  array->items[index] = item;
}

/*!
 * Insert an item at an index of a primitive array.
 *
 * @param array The primitive array.
 * @param item The item.
 * @param index The index of the item to insert.
 */
static inline void FOPrimitiveArrayInsertItemAtIndex(FOPrimitiveArray *array, FOPrimitiveArrayType item, NSUInteger index) {
  NSCParameterAssert(array != NULL);
  NSCParameterAssert(index <= array->count);
  if (array->capacity == array->count) {
    FOPrimitiveArrayGrowToCapacity(array, array->capacity * 2, index);
  } else {
    for (NSUInteger i = array->count; i > index; --i) {
      array->items[i] = array->items[i - 1];
    }
  }
  array->items[index] = item;
  ++array->count;
}

/*!
 * Remove the item at an index of a primitive array.
 *
 * @param array The primitive array.
 * @param index The index of the item to remove.
 */
static inline void FOPrimitiveArrayRemoveItemAtIndex(FOPrimitiveArray *array, NSUInteger index) {
  NSCParameterAssert(array != NULL);
  NSCParameterAssert(index < array->count);
  for (NSUInteger i = index + 1; i < array->count; ++i) {
    array->items[i - 1] = array->items[i];
  }
  --array->count;
#if (FOPrimitiveArrayTypeReference != 0)
  array->items[array->count] = nil;
#endif
}


/*!
 * Remove all items from a primitive array.
 *
 * @param array The primitive array.
 */
static inline void FOPrimitiveArrayRemoveAllItems(FOPrimitiveArray *array) {
  NSCParameterAssert(array != NULL);
#if (FOPrimitiveArrayTypeReference != 0)
  for (NSUInteger i = 0; i < array->count; ++i) {
    array->items[i] = nil;
  }
#endif
  array->count = 0;
}


#if (FOPrimitiveArrayTypeReference == 0)
# define FOPrimitiveArrayAllocItems(c) malloc(c * sizeof(FOPrimitiveArrayType))
#elif (FOPrimitiveArrayTypeReference == 1)
# define FOPrimitiveArrayAllocItems(c) (__strong FOPrimitiveArrayType *)calloc(c, sizeof(FOPrimitiveArrayType))
#else
# define FOPrimitiveArrayAllocItems(c) (__weak FOPrimitiveArrayType *)calloc(c, sizeof(FOPrimitiveArrayType))
#endif

static inline void FOPrimitiveArrayGrowToCapacity(FOPrimitiveArray *array, NSUInteger newCapacity, NSUInteger gapIndex) {
  NSCParameterAssert(array != NULL);
  NSCParameterAssert(newCapacity > array->capacity);
#if (FOPrimitiveArrayTypeReference == 0)
  FOPrimitiveArrayType *newItems;
#elif (FOPrimitiveArrayTypeReference == 1)
  __strong FOPrimitiveArrayType *newItems;
#else
  __weak FOPrimitiveArrayType *newItems;
#endif
  newItems = FOPrimitiveArrayAllocItems(newCapacity);
  if (array->items != NULL) {
    if (gapIndex != NSNotFound) {
      for (NSUInteger i = 0; i < gapIndex; ++i) {
        newItems[i] = array->items[i];
#if (FOPrimitiveArrayTypeReference != 0)
        array->items[i] = nil;
#endif
      }
      for (NSUInteger i = gapIndex; i < array->count; ++i) {
        newItems[i + 1] = array->items[i];
#if (FOPrimitiveArrayTypeReference != 0)
        array->items[i] = nil;
#endif
      }
    } else {
      for (NSUInteger i = 0; i < array->count; ++i) {
        newItems[i] = array->items[i];
#if (FOPrimitiveArrayTypeReference != 0)
        array->items[i] = nil;
#endif
      }
    }
    free(array->items);
  }
  array->capacity = newCapacity;
  array->items = newItems;
}

//#endif
