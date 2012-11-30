//
//  WizDocument.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"


static NSString* const  DataTypeUpdateDocumentGUID          =       @"document_guid";
static NSString* const DataTypeUpdateDocumentTitle          =       @"document_title";
static NSString* const DataTypeUpdateDocumentLocation       =       @"document_location";
static NSString* const DataTypeUpdateDocumentDataMd5        =       @"data_md5";
static NSString* const DataTypeUpdateDocumentUrl            =       @"document_url";
static NSString* const DataTypeUpdateDocumentTagGuids       =       @"document_tag_guids";
static NSString* const DataTypeUpdateDocumentDateCreated    =       @"dt_created";
static NSString* const DataTypeUpdateDocumentDateModified   =       @"dt_modified";
static NSString* const DataTypeUpdateDocumentType           =       @"document_type";
static NSString* const DataTypeUpdateDocumentFileType       =       @"document_filetype";
static NSString* const DataTypeUpdateDocumentAttachmentCount=       @"document_attachment_count";
static NSString* const DataTypeUpdateDocumentLocalchanged   =       @"document_localchanged";
static NSString* const DataTypeUpdateDocumentServerChanged  =       @"document_serverchanged";
static NSString* const DataTypeUpdateDocumentProtected      =       @"document_protect";
static NSString* const DataTypeUpdateDocumentGPS_LATITUDE   =       @"gps_latitude";
static NSString* const DataTypeUpdateDocumentGPS_LONGTITUDE =       @"gps_longitude";
static NSString* const DataTypeUpdateDocumentGPS_ALTITUDE   =       @"GPS_ALTITUDE";
static NSString* const DataTypeUpdateDocumentGPS_DOP        =       @"GPS_DOP";
static NSString* const DataTypeUpdateDocumentGPS_ADDRESS    =       @"GPS_ADDRESS";
static NSString* const DataTypeUpdateDocumentGPS_COUNTRY    =       @"GPS_COUNTRY";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL1     =       @"GPS_LEVEL1";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL2     =       @"GPS_LEVEL2";
static NSString* const DataTypeUpdateDocumentGPS_LEVEL3     =       @"GPS_LEVEL3";
static NSString* const DataTypeUpdateDocumentGPS_DESCRIPTION=       @"GPS_DESCRIPTION";
static NSString* const DataTypeUpdateDocumentREADCOUNT      =       @"READCOUNT";
static NSString* const DataTypeUpdateDocumentOwner          =       @"document_owner";

enum WizEditDocumentType {
    WizEditDocumentTypeNoChanged = 0,
    WizEditDocumentTypeAllChanged = 1,
    WizEditDocumentTypeInfoChanged =2
    };

@interface WizDocument : WizObject

@property (atomic, retain) NSString* strLocation;
@property (atomic, retain) NSString* strUrl;
@property (atomic, retain) NSDate* dateCreated;
@property (atomic, retain) NSDate* dateModified;
@property (atomic, retain) NSString* strType;
@property (atomic, retain) NSString* strFileType;
@property (atomic, retain) NSString* strTagGuids;
@property (atomic, retain) NSString* strDataMd5;
@property (atomic, assign) BOOL bServerChanged;
@property (atomic, assign) enum WizEditDocumentType nLocalChanged;
@property (atomic, assign) BOOL nProtected;
@property (atomic, assign) int nAttachmentCount;
@property (atomic, assign) float   gpsLatitude;
@property (atomic, assign) float   gpsLongtitude;
@property (atomic, assign) float   gpsAltitude;
@property (atomic, assign) float   gpsDop;
@property (atomic, assign) int nReadCount;
@property (atomic, retain) NSString* gpsAddress;
@property (atomic, retain) NSString* gpsCountry;
@property (atomic, retain) NSString* gpsLevel1;
@property (atomic, retain) NSString* gpsLevel2;
@property (atomic, retain) NSString* gpsLevel3;
@property (atomic, retain) NSString* gpsDescription;
@property (atomic, retain) NSString* strOwner;
- (NSDictionary*) getModelDictionary;
@end
