//
//  ViewController.h
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController


@end

class UIUpdater : public IUIUpdater
{
public:
   void UpdateUIOnStartingSDFileHistory() override;
   void UpdateUIOnFinishingSDFileHistory() override;
   void UpdateUIOnStartingScanningOfFileHistories() override;
   void UpdateUIOnEndingScanningOfFileHistories() override;
   void UpdateUIOnStartingGettingInfoOnPossibleCulpableChangelists() override;
   void UpdateUIOnEndingGettingInfoOnPossibleCulpableChangelists() override;
};
