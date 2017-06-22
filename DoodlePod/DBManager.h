//
//  DBManager.h
//  DoodlePod
//
//  Created by beacomni on 6/22/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <UIKit/UIKit.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager *) getSharedInstance;

-(BOOL) createDB;
- (BOOL) saveData:(int)savesetid position:(int)position xcoord:(int)x ycoord:(int)y;
- (int) getMaxSaveSetId;
- (NSMutableArray *) findAllBySaveSetId:(int)saveSetId;



@end
