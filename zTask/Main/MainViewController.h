//
//  MainViewController.h
//  PortSite
//
//  Created by ming lin on 4/3/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MainViewController : UIViewController <MBProgressHUDDelegate> {
    MBProgressHUD *hud;
}

@property(nonatomic, retain) IBOutlet UILabel *urlLabel;
@property(nonatomic, retain) IBOutlet UILabel *addressBarLabel;
@property(nonatomic, retain) IBOutlet UISwitch *serverSwitch;

@property(nonatomic, retain) IBOutlet UILabel *urlHintLabel;
@property(nonatomic, retain) IBOutlet UIImageView *addressBarImageView;

@end
