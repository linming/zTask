//
//  TaskViewController.m
//  zTask
//
//  Created by ming lin on 6/28/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TaskViewController.h"
#import "ProjectSelectorController.h"
#import "NoteViewController.h"
#import "PSLabelSwitchCell.h"
#import "FileUtil.h"
#import "DateUtil.h"
#import "Utils.h"
#import "AppDelegate.h"


#define SECTION_COUNT 2
#define SECTION_DETAIL 0
#define SECTION_ATTACHMENT 1

#define ROW_PROJECT 0
#define ROW_FLAG 1
#define ROW_FINISH_DATE 2

#define TAG_FINISH_DATE 101

@interface TaskViewController ()

@end

@implementation TaskViewController

@synthesize taskId, tasks, currentIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (taskId) {
        task = [Task find:taskId];
        attaches = [[Attach findAll:taskId] mutableCopy];
        self.navigationItem.title = @"Task";
        
        if (tasks != nil) {
            NSArray *buttonNames = [NSArray arrayWithObjects:[UIImage imageNamed:@"back"], [UIImage imageNamed:@"forward"], nil];
            navSegmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
            navSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
            navSegmentedControl.momentary = YES;
            [navSegmentedControl addTarget:self action:@selector(taskNavAction) forControlEvents:UIControlEventValueChanged];
            UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:navSegmentedControl];
            self.navigationItem.rightBarButtonItem = segButton;
            [self updateNavSegmentedControlStatus];
        }
    } else {
        task = [[Task alloc] init];
        attaches = [NSMutableArray array];
        if (self.project) {
            task.projectId = self.project.rowid;
            projectButton.titleLabel.text = self.project.name;
        }
        
        self.navigationItem.title = @"New Task";
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
        
        UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = saveButtonItem;
    }
    
    [self updateTableViewHeaderWithHeight:0];
    [self updateTableFooterView];
    

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)reloadTaskView
{
    task = [Task find:taskId];
    attaches = [[Attach findAll:taskId] mutableCopy];
    titleTextView.text = task.title;
    [statusControl setIsSelected:task.status];
    [self.tableView reloadData];
}

- (void)hideKeyboard
{
    [titleTextView resignFirstResponder];
    [completedTextField resignFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidDisappear:(BOOL)animated
{
    if (taskId) {
        [Task update:task];
    }
    [self stopAudio];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_DETAIL) {
        return task.status ? 3 : 2;
    } else if (section == SECTION_ATTACHMENT) {
        return [attaches count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_ATTACHMENT) {
        return 30;
    } else {
        return 0;
    }
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_ATTACHMENT) {
        UIView *headerView  = [[UIView alloc] init];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Attachments";
        [titleLabel setFrame:CGRectMake(13, 3, 200, 24)];
        [titleLabel setBackgroundColor:[tableView backgroundColor]];
        [headerView addSubview:titleLabel];
        
        if (!audioRecorder.recording && !audioPlayer.playing) {
            if ([attaches count] > 0) {
                editButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [editButton setFrame:CGRectMake(250, 3, 50, 24)];
                editButton.layer.cornerRadius = 5;
                editButton.layer.borderWidth = 1;
                editButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
                [editButton setTitle:@"Edit" forState:UIControlStateNormal];
                [editButton addTarget:self action:@selector(editAttach) forControlEvents:UIControlEventTouchUpInside];
                [editButton setBackgroundColor: [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0]];
                [headerView addSubview:editButton];
            }
        }
        
        return headerView;
    } else {
        return nil;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SECTION_DETAIL:
            switch (indexPath.row) {
                case ROW_PROJECT: 
                {
                    NSString *CellIdentifier = @"CELL_DETAIL_PROJECT";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"Project";
                        projectButton = [[UIButton alloc] init];
                        [projectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [projectButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];

                        [projectButton addTarget:self action:@selector(showProjectSelector) forControlEvents:UIControlEventTouchUpInside];
                        projectButton.frame = CGRectMake(120, 5, 168, 34);
                        [cell.contentView addSubview:projectButton];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    
                    if (task.projectId) {
                        Project *project = [Project find:task.projectId];
                        [projectButton setTitle:project.name forState:UIControlStateNormal];
                    } else {
                        [projectButton setTitle:@"None" forState:UIControlStateNormal];
                    }
                    
                    return cell;
                    break;
                }
                case ROW_FLAG: 
                {
                    NSString *CellIdentifier = @"CELL_DETAIL_FLAG";
                    PSLabelSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[PSLabelSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"Flag";
                        flagSwitch = cell.switcher;
                        [cell.switcher addTarget:self action:@selector(flagSwitchDidChange) forControlEvents:UIControlEventValueChanged];
                    }
                    [cell.switcher setOn:task.flag];
                    return cell;
                    break;
                }
                case ROW_FINISH_DATE: 
                {
                    NSString *CellIdentifier = @"CELL_DETAIL_FINISH";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"Completed";
                        completedTextField = [[UITextField alloc] initWithFrame:CGRectMake(198.0, 9.0, 94.0, 27.0)];

                        
                        completedTextField.tag = TAG_FINISH_DATE;
                        completedTextField.delegate = self;
                        
                        completedPicker = [[UIDatePicker alloc] init];
                        completedPicker.datePickerMode = UIDatePickerModeDate;
                        [completedPicker addTarget:self action:@selector(completedPickerValueChanged) forControlEvents:UIControlEventValueChanged];
                        completedPicker.tag = indexPath.row;
                        completedTextField.inputView = completedPicker;
                        
                        [cell.contentView addSubview:completedTextField];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    if (task.completed) {
                        completedTextField.text = [task getCompletedStr];
                    } else {
                        completedTextField.text = @"None";
                    }
                    return cell;
                    break;
                }
                default:
                    break;
            }
            break;
        case SECTION_ATTACHMENT:
        {
            NSString *CellIdentifier = @"CELL_ATTACHMENT";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            Attach *attach = [attaches objectAtIndex:indexPath.row];
            if ([attach.type isEqualToString:@"Audio"]) {
                cell.imageView.image = [UIImage imageNamed:@"audio"];
                if ([attach.audioStatus isEqualToString:@"playing"]) {
                    playerMeterView = [[AVPlayerMeterView alloc] initWithFrame:CGRectMake(22,  4, 240, 28)];
                    playerMeterView.audioPlayer = audioPlayer;
                    [playerMeterView startUpdating];
                    [cell.contentView addSubview:playerMeterView];
                } else if ([attach.audioStatus isEqualToString:@"recording"]) {
                    recorderMeterView = [[AVRecorderMeterView alloc] initWithFrame:CGRectMake(22,  4, 240, 28)];
                    recorderMeterView.audioRecorder = audioRecorder;
                    [recorderMeterView startUpdating];
                    [cell.contentView addSubview:recorderMeterView];
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"Audio recorded %@", [attach getCreatedInterval]];
                }
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Picture taken %@", [attach getCreatedInterval]];
                UIImage *image = [UIImage imageWithContentsOfFile: [attach getPath]];
                cell.imageView.image = [Utils scaleImage:image size:CGSizeMake(32, 32)];
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
            return cell;
            break;   
        }
        default:
            break;
    }
    return nil;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == SECTION_ATTACHMENT) {
        return YES;
    } else {
        return NO;        
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == SECTION_ATTACHMENT) {
            Attach *attach = [attaches objectAtIndex:indexPath.row];
            [Attach remove:attach];
            [attaches removeObject:attach];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];            
        }

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
    if (indexPath.section == SECTION_DETAIL && indexPath.row == ROW_PROJECT) {

    }
     */
        
        
    if (indexPath.section == SECTION_ATTACHMENT) {
        Attach *attach = [attaches objectAtIndex:indexPath.row];
        if ([attach.type isEqualToString:@"Audio"]) {
            [self playAudio: attach];
        } else {            
            UIImage *image = [UIImage imageWithContentsOfFile: [attach getPath]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

            [imageView setFrame:CGRectMake(0, 0, 320, 480)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            imageView.backgroundColor = [UIColor clearColor];
            imageView.opaque = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            zoomImageView = [[ZoomImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) withImageView:imageView];
            [zoomImageView calculateZoomSize:image];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.window addSubview:zoomImageView];
        }
    }
}


#pragma mark - Table view actions

- (void)save 
{
    task.title = titleTextView.text;
    task.flag = flagSwitch.on;
    task.rowid = [Task create:task];
    
    if ([attaches count] > 0) {
        NSString *relativePath = [NSString stringWithFormat:@"/files/tasks/%d", task.rowid];
        [FileUtil makeFilePath:relativePath];
        
        for (Attach *attach in attaches) {
            attach.taskId = task.rowid;
            [Attach create:attach];
        }
    }

    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancel 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showDetail 
{
    NoteViewController *noteViewController = [[NoteViewController alloc]initWithNibName:@"NoteViewController" bundle:nil];
    noteViewController.taskViewController = self;
    noteViewController.taskTitle = titleTextView.text;
    noteViewController.taskNote = task.note;
    [self.navigationController pushViewController:noteViewController animated:YES];
}

- (void)showProjectSelector
{
    ProjectSelectorController *projectSelectorController = [[ProjectSelectorController alloc] initWithNibName:@"ProjectSelectorController" bundle:nil];
    projectSelectorController.taskViewController = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:projectSelectorController];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)flagSwitchDidChange
{
    task.flag = flagSwitch.on;
}

- (void)changeTaskStatus
{
    task.status = statusControl.isSelected;
    if (task.status) {
        task.completed = [NSDate date];
    }
    [self.tableView reloadData];
}

- (void)completedPickerValueChanged
{
    completedTextField.text = [DateUtil formatDate:completedPicker.date to:@"yyyy-MM-dd"];
    task.completed = completedPicker.date;
}

- (void)takePhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
}

- (void)pickPhoto 
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - Attach Actions
- (void)editAttach
{
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
        [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    } else {
        [self.tableView setEditing:YES];
        [editButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
}

- (Attach *)addAttach:(NSString *)name type:(NSString *)type audioStatus:(NSString *)audioStatus
{
    Attach *attach = [[Attach alloc] init];
    attach.name = name;
    attach.type = type;
    attach.taskId = task.rowid;
    attach.created = [NSDate date];
    
    if (audioStatus) {
        attach.audioStatus = audioStatus;
    }
    if (taskId) {
        attach.rowid = [Attach create:attach];
    }
    
    return attach;
}


#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo 
{
    NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)[[NSDate date] timeIntervalSince1970]];
    Attach *attach = [self addAttach:imageName type:@"Photo" audioStatus:nil];
    
    UIImage *sImage = [Utils scaleAndRotateImage:image];
    
    NSData *imageData = UIImagePNGRepresentation(sImage);
    [imageData writeToFile:[attach getPath] atomically:NO];
    
    NSLog(@"attach path: %@", [attach getPath]);
    
    [picker dismissModalViewControllerAnimated:YES];
    
    [attaches addObject:attach];
    [self.tableView reloadData];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Audio Actions
- (void)prepareAudio:(NSString *)path 
{
    NSLog(@"prepare audio");
    NSURL *soundFileURL = [NSURL fileURLWithPath:path];
    
    NSDictionary *recordSettings = [NSDictionary 
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:8], 
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1], 
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:11025.0], 
                                    AVSampleRateKey,
                                    [NSNumber numberWithInt: kAudioFormatAppleIMA4], 
                                    AVFormatIDKey,
                                    nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"set delegate ......");
        [audioRecorder setDelegate:self];
        [audioRecorder prepareToRecord];
    }
}
- (void)recordAudio 
{
    NSLog(@"record audio");
    
    NSString *soundFileName = [NSString stringWithFormat:@"%ld.caf", (long)[[NSDate date] timeIntervalSince1970]];
    Attach *attach = [self addAttach:soundFileName type:@"Audio" audioStatus:@"recording"];
    [self prepareAudio: [attach getPath]];
    if (!audioRecorder.recording) {
        [audioRecorder record];
    }
    
    [self updateAudioStatus];
    [attaches addObject:attach];
    [self.tableView reloadData];
}

- (void)stopAudio 
{
    if (audioRecorder.recording) {
        [recorderMeterView stopUpdating];
        recorderMeterView.audioRecorder = nil;
        [audioRecorder stop];
    } 
    
    if (audioPlayer.playing) {
        [playerMeterView stopUpdating];
        playerMeterView.audioPlayer = nil;
        [audioPlayer stop];
    }
    //stop all
    for (Attach *attach in attaches) {
        attach.audioStatus = @"stop";
    }
    [self updateAudioStatus];
    [self.tableView reloadData];
}


- (void)playAudio: (Attach *)attach {    
    NSURL *soundFileURL = [NSURL fileURLWithPath:[attach getPath]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] 
                   initWithContentsOfURL:soundFileURL                                   
                   error:&error];
    
    audioPlayer.delegate = self;
    
    if (error)
        NSLog(@"Error: %@", [error localizedDescription]);
    else
        [audioPlayer play];
    attach.audioStatus = @"playing";
    [self updateAudioStatus];
    [self.tableView reloadData];
}

#pragma mark - Audio Player&Recorder Delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [playerMeterView stopUpdating];
    playerMeterView.audioPlayer = nil;
    [recordAudioButton setTitle:@"Record Audio" forState:UIControlStateNormal];
    [self stopAudio];
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player 
                                error:(NSError *)error {
    NSLog(@"Decode Error occurred: audioPlayerDecodeErrorDidOccur");
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder 
                          successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording");
    [self stopAudio];
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder 
                                  error:(NSError *)error {
    NSLog(@"Encode Error occurred: audioRecorderEncodeErrorDidOccur");
}

#pragma mark - TextView Delegate
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
	return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    [self updateTableViewHeaderWithHeight:height];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    task.title = growingTextView.text;
}

#pragma mark - TextField Delegater
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

#pragma mark - TableView Header & Footer
- (void)updateTableViewHeaderWithHeight:(float)height
{
    if (height == 0) {
        height = 44;
    }
    
    if (taskViewHeaderContainer == nil) {
        taskViewHeaderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
        
        statusControl = [[ToggleImageControl alloc] initWithFrame: CGRectMake(10, 10, 24, 24) status:task.status];
        [statusControl addTarget:self action:@selector(changeTaskStatus) forControlEvents:UIControlEventTouchUpInside];
        [taskViewHeaderContainer addSubview:statusControl];
        
        titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(40, 4, 240, 24)];
        [titleTextView setMinNumberOfLines : 1];
        [titleTextView setMaxNumberOfLines : 3];
        titleTextView.returnKeyType = UIReturnKeyDone;
        titleTextView.font = [UIFont boldSystemFontOfSize:15.0f];
        titleTextView.delegate = self;
        titleTextView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
        if (taskId) {
            titleTextView.text = task.title;
        } else {
            [titleTextView becomeFirstResponder];
        }
        [taskViewHeaderContainer addSubview:titleTextView];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure]; 
        detailButton.frame = CGRectMake(285, 5, 29, 31);
        [detailButton addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
        [taskViewHeaderContainer addSubview:detailButton];
        
        taskViewHeaderContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
        taskViewHeaderContainer.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        taskViewHeaderContainer.layer.shadowOpacity = 1;
        taskViewHeaderContainer.layer.masksToBounds = NO;
        taskViewHeaderContainer.layer.borderWidth = 1.0f;
        taskViewHeaderContainer.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];

        
    } else {
        taskViewHeaderContainer.frame = CGRectMake(0, 0, 320, height + 9);
    }

    
    [self.tableView setTableHeaderView:taskViewHeaderContainer];
    
}

- (void)updateTableFooterView
{
    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takePhotoButton setFrame:CGRectMake(10, 3, 145, 44)];
    [takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:takePhotoButton];
    
    UIButton *pickPhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pickPhotoButton setFrame:CGRectMake(165, 3, 145, 44)];
    [pickPhotoButton setTitle:@"Pick Photo" forState:UIControlStateNormal];
    [pickPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pickPhotoButton addTarget:self action:@selector(pickPhoto) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:pickPhotoButton];
    
    recordAudioButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [recordAudioButton setFrame:CGRectMake(87, 53, 146, 44)];
    [recordAudioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self updateAudioStatus];
    
    [footerView addSubview:recordAudioButton];
    [self.tableView setTableFooterView:footerView];
}

- (void)updateAudioStatus
{
    if (audioRecorder.recording || audioPlayer.playing) {
        [recordAudioButton setTitle:@"Stop" forState:UIControlStateNormal];
        [recordAudioButton removeTarget:self action:@selector(recordAudio) forControlEvents:UIControlEventTouchUpInside];
        [recordAudioButton addTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [recordAudioButton setTitle:@"Record Audio" forState:UIControlStateNormal];
        [recordAudioButton removeTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
        [recordAudioButton addTarget:self action:@selector(recordAudio) forControlEvents:UIControlEventTouchUpInside];
    }
    [playerMeterView removeFromSuperview];
    [recorderMeterView removeFromSuperview];
}

#pragma mark - Set Value Callback Function
- (void)updateProject:(NSInteger)projectId projectName:(NSString *)projectName
{
    task.projectId = projectId;
    [projectButton setTitle:projectName forState:UIControlStateNormal];
}

- (void)updateNote:(NSString *)note
{
    task.note = note;
}

#pragma mark - task nav button action

- (void)taskNavAction
{
	switch (navSegmentedControl.selectedSegmentIndex) {
        case 0:
            if (currentIndex > 0) {
                currentIndex--;
                task = [tasks objectAtIndex:currentIndex];
                taskId = task.rowid;
                [self reloadTaskView];
            }
            break;
        case 1:
            if(currentIndex < [tasks count] - 1) {
                currentIndex++;
                task = [tasks objectAtIndex:currentIndex];
                taskId = task.rowid;
                [self reloadTaskView];
            }
            break;
        default:
            break;
    }
    [self updateNavSegmentedControlStatus];
}

- (void)updateNavSegmentedControlStatus
{
    if ([tasks count] == 1) {
        [navSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [navSegmentedControl setEnabled:NO forSegmentAtIndex:1];
    } else if (currentIndex == 0) {
        [navSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [navSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else if (currentIndex == [tasks count] - 1) {
        [navSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [navSegmentedControl setEnabled:NO forSegmentAtIndex:1];
    } else {
        [navSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [navSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    }
}

@end
