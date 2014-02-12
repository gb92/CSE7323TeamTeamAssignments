//
//  FavoriteWord.h
//  Assignment1
//
//  Created by Gavin Benedict on 2/4/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FavoriteWord:NSManagedObject

@property (nonatomic, retain) NSString *favoriteWord;

@property (nonatomic, retain) NSString *numTimesUsedPerDay;


@end
