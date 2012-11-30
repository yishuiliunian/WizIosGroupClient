//
//  WizSettingsDataBase.h
//  Wiz
//
//  Created by wiz on 12-6-21.
//
//

#import "WizDataBase.h"
#import "WizSettingsDbDelegate.h"

enum WizImageQuality {
    WizImageQualityOrigin = 1024,
    WizImageQualityLarge = 1024,
    WizImageQualityMiddle = 768,
    WizImageQualitySmall= 300
    };

@interface WizSettingsDataBase : WizDataBase <WizSettingsDbDelegate>

@end
