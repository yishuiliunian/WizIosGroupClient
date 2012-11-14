//
//  WizDataBase.h
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import <UIKit/UIKit.h>
#import "FMDataBase.h"
#import "FMDatabaseQueue.h"
@interface WizDataBase : NSObject
{
    FMDatabaseQueue* queue;
}
@property (atomic, readonly) FMDatabaseQueue* queue;
- (WizDataBase*) initWithPath:(NSString*)dbPath modelName:(NSString*)modelName;
- (void) close;
@end
