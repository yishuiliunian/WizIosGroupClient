//
//  WizApi.m
//  WizCore
//
//  Created by wiz on 12-8-1.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApi.h"
#import "WizSyncErrorCenter.h"
#import "WizSyncDataCenter.h"
#import "WizGlobals.h"

NSString* const SyncMethod_ClientLogin                  = @"accounts.clientLogin";
NSString* const SyncMethod_ClientLogout                 = @"accounts.clientLogout";
NSString* const SyncMethod_CreateAccount                = @"accounts.createAccount";
NSString* const SyncMethod_ChangeAccountPassword        = @"accounts.changePassword";
NSString* const SyncMethod_GetAllCategories             = @"category.getAll";
NSString* const SyncMethod_GetAllTags                   = @"tag.getList";
NSString* const SyncMethod_PostTagList                  = @"tag.postList";
NSString* const SyncMethod_DocumentsByKey               = @"document.getSimpleListByKey";
NSString* const SyncMethod_DownloadDocumentList         = @"document.getSimpleList";
NSString* const SyncMethod_DocumentsByCategory          = @"document.getSimpleListByCategory";
NSString* const SyncMethod_DocumentsByTag               = @"document.getSimpleListByTag";
NSString* const SyncMethod_DocumentPostSimpleData       = @"document.postSimpleData";
NSString* const SyncMethod_DownloadDeletedList          = @"deleted.getList";
NSString* const SyncMethod_UploadDeletedList            = @"deleted.postList";
NSString* const SyncMethod_DownloadObject               = @"data.download";
NSString* const SyncMethod_UploadObject                 = @"data.upload";
NSString* const SyncMethod_AttachmentPostSimpleData     = @"attachment.postSimpleData";
NSString* const SyncMethod_GetAttachmentList            = @"attachment.getList";
NSString* const SyncMethod_GetUserInfo                  = @"wiz.getInfo";
NSString* const SyncMethod_GetGropKbGuids               = @"accounts.getGroupKbList";
NSString* const SyncMethod_GetAllObjectVersion          = @"wiz.getVersion";

@implementation WizApi
@synthesize apiDelegate;
@synthesize statue = _statue;
@synthesize connection;
@synthesize kbGuid;
@synthesize accountUserId;
- (void) dealloc
{
    apiDelegate = nil;
    [connection release];
    [accountUserId release];
    [kbGuid release];
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if (self) {
        attemptTime = WizApiAttemptTimeMax;
    }
    return self;
}

- (BOOL) start
{
    if (attemptTime <= 0) {
        [self changeStatue:WizApistatueError];
        [self end];
        return NO;
    }
    [self changeStatue:WizApiStatueBusy];
    WizLogDebug(@"start sync class %@",[self class]);
    //
    return YES;
}

- (void) reduceAttempTime
{
    attemptTime--;
}

- (void) onError:(NSError *)error
{
    [self changeStatue:WizApistatueError];
    WizSyncErrorCenter* errorCenter = [WizSyncErrorCenter shareInstance];
    [errorCenter willSolveWizApi:self onError:error];
    WizLogDebug(@"error is %@",error);
}

- (void) cancel
{
    if (self.connection) {
        [self.connection cancel];
    }
    self.connection = nil;
}

- (void) end
{
    enum WizApiStatue oldStatue = _statue;
    
    [self changeStatue:WizApiStatueNormal];
        switch (oldStatue) {
            case WizApiStatueBusy:
                [self.apiDelegate wizApiEnd:self withSatue:WizApiStatueNormal];
                break;
            case WizApistatueError:
                [self.apiDelegate wizApiEnd:self withSatue:WizApistatueError];
            default:
                [self.apiDelegate wizApiEnd:self withSatue:WizApiStatueNormal];
                break;
        }
}

-(void) addCommonParams: (NSMutableDictionary*)postParams
{
	[postParams setObject:@"iphone" forKey:@"client_type"];
	[postParams setObject:@"normal" forKey:@"program_type"];
    [postParams setObject:[NSNumber numberWithInt:4] forKey:@"api_version"];
	//
	if (kbGuid != nil)
	{
		[postParams setObject:kbGuid forKey:@"kb_guid"];
	}
}
-(BOOL)executeXmlRpcWithArgs:(NSMutableDictionary*)postParams  methodKey:(NSString*)methodKey  needToken:(BOOL)isNeedToken
{
    
    if (isNeedToken) {
        NSString* token = [[WizSyncDataCenter shareInstance] tokenForAccount:self.accountUserId];
        if (token != nil)
        {
            [postParams setObject:token forKey:@"token"];
        }
        else
        {
            [[WizSyncErrorCenter shareInstance] willSolveWizApi:self onError:[NSError errorWithDomain:WizErrorDomain code:WizSyncErrorTokenUnactive userInfo:nil]];
            return NO;
        }
    }
    NSURL* apiUrl = [[WizSyncDataCenter shareInstance] apiUrlForKbguid:self.kbGuid];
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:apiUrl];
	if (!request)
    {
		return NO;
    }
    [self addCommonParams:postParams];
    NSArray* args = [NSArray arrayWithObject:postParams];
	//
	[request setMethod:methodKey withObjects:args];
	//
	self.connection = [XMLRPCConnection sendAsynchronousXMLRPCRequest:request delegate:self];
	//
	[request release];
	//
    if(nil != self.connection)
        return YES;
    else
        return NO;
}

- (void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method
{
    self.connection = nil;
    if (succeeded) {
        [self xmlrpcDoneSucced:ret forMethod:method];
    }
    else
    {
        [self onError:ret];
    }
}

- (id<WizMetaDataBaseDelegate>)groupDataBase
{
    return [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
}

- (NSInteger) listCount
{
    return 50;
}
- (NSString*) apiStatueKey
{
    return [NSString stringWithFormat:@"%@%@%@",self.kbGuid,self.accountUserId,self];
}
- (void) changeStatue:(WizApiStatue)statue
{
    _statue = statue;
    if (self.apiDelegate) {
        [self.apiDelegate wizApiDidChangedStatue:statue forKey:[self apiStatueKey]];
    }
}

- (id) initWithKbguid:(NSString *)kbguid_ accountUserId:(NSString *)accountUserId_ apiDelegate:(id<WizApiDelegate>)delegate
{
    self = [super init];
    if (self) {
        attemptTime = WizApiAttemptTimeMax;
        kbGuid = [kbguid_ retain];
        accountUserId = [accountUserId_ retain];
        apiDelegate = delegate;
    }
    return self;
}

- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    
}
@end
