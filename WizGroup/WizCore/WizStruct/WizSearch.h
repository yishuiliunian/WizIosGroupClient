//
//  WizSearch.h
//  Wiz
//
//  Created by wiz on 12-7-20.
//
//

#import <Foundation/Foundation.h>

@interface WizSearch : NSObject
@property (nonatomic, retain) NSString* strKeyWords;
@property (nonatomic, retain) NSDate* dateLastSearched;
@property (nonatomic, assign) NSInteger  nNotesNumber;
@property (nonatomic, assign) BOOL       bSearchLocal;
@end
