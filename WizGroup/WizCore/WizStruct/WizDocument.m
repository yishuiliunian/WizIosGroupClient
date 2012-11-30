//
//  WizDocument.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocument.h"

@implementation WizDocument
@synthesize strLocation;
@synthesize strUrl;
@synthesize dateCreated;
@synthesize dateModified;
@synthesize strType;
@synthesize strFileType;
@synthesize strTagGuids;
@synthesize strDataMd5;
@synthesize bServerChanged;
@synthesize nLocalChanged;
@synthesize nProtected;
@synthesize nAttachmentCount;
@synthesize gpsLatitude;
@synthesize gpsLongtitude;
@synthesize gpsAltitude;
@synthesize gpsDop;
@synthesize nReadCount;
@synthesize gpsAddress;
@synthesize gpsCountry;
@synthesize gpsLevel1;
@synthesize gpsLevel2;
@synthesize gpsLevel3;
@synthesize gpsDescription;
@synthesize strOwner;
- (void) dealloc
{
    [strOwner release];
    [strLocation release];
    [strUrl release];
    [dateCreated release];
    [dateModified release];
    [strType release];
    [strFileType release];
    [strTagGuids release];
    [strDataMd5 release];
    [gpsCountry release];
    [gpsAddress release];
    [gpsLevel1 release];
    [gpsLevel2 release];
    [gpsLevel3 release];
    [gpsDescription release];
    [super dealloc];
}
- (NSString*) wizObjectType
{
    return @"document";
}

- (NSDictionary*) getModelDictionary
{
    if (self.strGuid == nil || [self.strGuid isBlock]) {
        self.strGuid = [WizGlobals genGUID];
    }
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithCapacity:14];
    [doc setObject:self.strGuid forKey:DataTypeUpdateDocumentGUID];
    [doc setObject:[NSNumber numberWithBool:self.bServerChanged] forKey:DataTypeUpdateDocumentServerChanged];
    [doc setObject:[NSNumber numberWithInt:self.nLocalChanged] forKey:DataTypeUpdateDocumentLocalchanged];
    [doc setObject:[NSNumber numberWithBool:self.nProtected] forKey:DataTypeUpdateDocumentProtected];
    [doc setObject:[NSNumber numberWithInt:self.nAttachmentCount] forKey:DataTypeUpdateDocumentAttachmentCount];
    if (nil!= self.gpsAddress) {
    }
    if (nil == self.strType)
    {
        self.strType = @"note";
    }
    [doc setObject:self.strType forKey:DataTypeUpdateDocumentType];
    if (nil == self.strUrl) {
        self.strUrl = @"";
    }
    [doc setObject:self.strUrl forKey:DataTypeUpdateDocumentUrl];
    if (nil == self.strLocation || [self.strLocation isBlock]) {
        self.strLocation = @"/My Notes/";
    }
    [doc setObject:self.strLocation forKey:DataTypeUpdateDocumentLocation];
    if (nil == self.strTitle || [self.strTitle isBlock]) {
        self.strTitle = WizStrNoTitle;
    }
    [doc setObject:self.strTitle forKey:DataTypeUpdateDocumentTitle];
    if (nil == self.strTagGuids) {
        self.strTagGuids = @"";
    }
    [doc setObject:self.strTagGuids forKey:DataTypeUpdateDocumentTagGuids];
    if (nil == self.strFileType) {
        self.strFileType = @"";
    }
    [doc setObject:self.strFileType forKey:DataTypeUpdateDocumentFileType];
    if (nil == self.dateCreated ) {
        self.dateCreated = [NSDate date];
    }
    [doc setObject:self.dateCreated forKey:DataTypeUpdateDocumentDateCreated];
    if (nil == self.dateModified) {
        self.dateModified = [NSDate date];
    }
    [doc setObject:self.dateModified forKey:DataTypeUpdateDocumentDateModified];
    if (nil == self.strDataMd5 || [self.strDataMd5 isBlock]) {
        //md5
        self.strDataMd5 = @"";
    }
    [doc setObject:self.strDataMd5 forKey:DataTypeUpdateDocumentDataMd5];
    
    if (self.gpsAddress) {
        [doc setObject:self.gpsAddress forKey:DataTypeUpdateDocumentGPS_ADDRESS];
    }
    if (self.gpsCountry) {
        [doc setObject:self.gpsCountry forKey:DataTypeUpdateDocumentGPS_COUNTRY];
    }
    if (self.gpsLevel1) {
        [doc setObject:self.gpsLevel1 forKey:DataTypeUpdateDocumentGPS_LEVEL1];
    }
    if (self.gpsLevel2) {
        [doc setObject:self.gpsLevel2 forKey:DataTypeUpdateDocumentGPS_LEVEL2];
    }
    if (self.gpsLevel3) {
        [doc setObject:self.gpsLevel3 forKey:DataTypeUpdateDocumentGPS_LEVEL3];
    }
    if (self.gpsDescription) {
        [doc setObject:self.gpsDescription forKey:DataTypeUpdateDocumentGPS_DESCRIPTION];
    }
    [doc setObject:[NSNumber numberWithFloat:self.gpsLatitude] forKey:DataTypeUpdateDocumentGPS_LATITUDE];
    [doc setObject:[NSNumber numberWithFloat:self.gpsLongtitude] forKey:DataTypeUpdateDocumentGPS_LONGTITUDE];
    [doc setObject:[NSNumber numberWithFloat:self.gpsAltitude] forKey:DataTypeUpdateDocumentGPS_ALTITUDE];
    [doc setObject:[NSNumber numberWithFloat:self.gpsDop] forKey:DataTypeUpdateDocumentGPS_DOP];
    [doc setObject:[NSNumber numberWithInt:self.nReadCount] forKey:DataTypeUpdateDocumentREADCOUNT];
    return doc;
}


@end
