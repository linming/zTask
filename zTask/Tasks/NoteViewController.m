//
//  NoteViewController.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize taskViewController, titleLabel, noteTextView, taskTitle, taskNote, titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Notes";
    
    titleLabel.text = taskTitle;
    noteTextView.text = taskNote;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [titleView addGestureRecognizer:gestureRecognizer];
    
    if (!taskNote || [taskNote isEqualToString:@""]) {
        [noteTextView becomeFirstResponder];
    }
}

- (void)hideKeyboard 
{
    [noteTextView resignFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidDisappear:(BOOL)animated
{
    [taskViewController updateNote:noteTextView.text];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];    
    float remainHeight = 480 - 20 - 44 - 44 - keyboardEndFrame.size.height;
    noteTextView.frame = CGRectMake(0, 44, 320, remainHeight);
}

@end
