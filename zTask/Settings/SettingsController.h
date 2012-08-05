//
//  SettingsController.h
//  PortSite
//
//  Created by ming lin on 4/3/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UITableViewController <UITextFieldDelegate>
{
    UISwitch *passwordSwitch;
    UITextField *passwordTextField;
    UITextField *portTextField;
}

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSArray *sections;

@end
