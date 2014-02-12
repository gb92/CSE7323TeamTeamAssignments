//
//  Assignment1AppDelegate.h
//  Assignment1
//
//  Created by Gavin Benedict on 1/29/14.
//  Copyright (c) 2014 Team Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Assignment1AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(NSArray *) getAllFavoriteWordsFromModel;

@end
