//
//  DBManager.m
//  DoodlePod
//
//  Created by beacomni on 6/22/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "DBManager.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager


+(DBManager *) getSharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    
    return sharedInstance;
}


-(BOOL) createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"DrawingData.db"]];
    
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            //format for date '2007-01-01 10:00:00'
            //yyyy-MM-dd HH:mm:ss
            char *errMsg;
            /*const char *sql_stmt = "create table if not exists drawing (regno integer primary key, xcoord int, ycoord int, savedate DATETIME)";*/
            const char *sql_stmt = "create table if not exists drawing (regno integer primary key,savesetid int,position int, xcoord int, ycoord int)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}


//- (BOOL) saveData:(NSString *)registerNumber xcoord:(int)x ycoord:(int)y savedate:(NSString *)savedate;
- (BOOL) saveData:(int)savesetid position:(int)position xcoord:(int)x ycoord:(int)y
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into drawing (regno,savesetid,position,xcoord, ycoord) values (NULL,%d,%d,%d,%d)",savesetid,position, x, y];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            const char *err = sqlite3_errmsg(database);
            return NO;
        }
        
        //sqlite3_reset(statement);
    }
    
    return NO;
}

- (int) getMaxSaveSetId{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"select max(savesetid) from drawing";
        const char *query_stmt = [querySQL UTF8String];
        int maxSaveSetId = -1;
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            /*if(sqlite3_column_type(query_stmt, 1) == SQLITE_NULL )
            {
                return 0;
            }*/
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                maxSaveSetId = sqlite3_column_int(statement, 0);
            }
                        sqlite3_finalize(statement);
                            return maxSaveSetId;
        }
    }
    return -1;
}

- (NSMutableArray *) findAllBySaveSetId:(int)saveSetId
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select regno, savesetid,position, xcoord, ycoord from drawing where savesetid = %d order by position",saveSetId];
        const char *query_stmt = [querySQL UTF8String];
        
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                int regno = sqlite3_column_int(statement, 0);
                int savesetid = sqlite3_column_int(statement, 1);
                int position = sqlite3_column_int(statement, 2);
                int xcoord = sqlite3_column_int(statement, 3);
                int ycoord = sqlite3_column_int(statement, 4);
                
                NSValue *point = [NSValue valueWithCGPoint:CGPointMake(xcoord, ycoord)];
                [resultArray addObject:point];
            }
            
            // Release the compiled statement from memory.
            sqlite3_finalize(statement);
            
            return resultArray;
        }
        
        // Close the database.
        sqlite3_close(database);
    }
    
    return nil;
}

/*- (NSArray*) findByRegisterNumber:(NSString*)registerNumber
 {
 const char *dbpath = [databasePath UTF8String];
 if (sqlite3_open(dbpath, &database) == SQLITE_OK)
 {
 NSString *querySQL = [NSString stringWithFormat:@"select xcoord,ycoord from drawing where regno=\"%@\"",registerNumber];
 const char *query_stmt = [querySQL UTF8String];
 NSMutableArray *resultArray = [[NSMutableArray alloc]init];
 
 if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
 {
 if (sqlite3_step(statement) == SQLITE_ROW)
 {
 NSString *xcoord = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
 NSString *ycoord = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
 [resultArray addObject:xcoord];
 [resultArray addObject:ycoord];
 return resultArray;
 }
 else{
 NSLog(@"Not found");
 return nil;
 }
 
 //sqlite3_reset(statement);
 }
 }
 
 return nil;
 }*/

/*
 - (NSArray*) findByRegisterNumber:(NSString*)registerNumber
 {
 const char *dbpath = [databasePath UTF8String];
 if (sqlite3_open(dbpath, &database) == SQLITE_OK)
 {
 NSString *querySQL = [NSString stringWithFormat:@"select name, department, year from studentsDetail where regno=\"%@\"",registerNumber];
 const char *query_stmt = [querySQL UTF8String];
 NSMutableArray *resultArray = [[NSMutableArray alloc]init];
 
 if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
 {
 if (sqlite3_step(statement) == SQLITE_ROW)
 {
 NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
 [resultArray addObject:name];
 NSString *department = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
 [resultArray addObject:department];
 NSString *year = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
 [resultArray addObject:year];
 return resultArray;
 }
 else{
 NSLog(@"Not found");
 return nil;
 }
 
 //sqlite3_reset(statement);
 }
 }
 
 return nil;
 }
 */
@end
