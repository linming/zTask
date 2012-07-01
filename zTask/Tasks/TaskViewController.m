//
//  TaskViewController.m
//  zTask
//
//  Created by ming lin on 6/28/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TaskViewController.h"
#import "ToggleImageControl.h"
#import "ProjectSelectorController.h"
#import "ImageViewController.h"
#import "NoteViewController.h"
#import "PSLabelSwitchCell.h"
#import "FileUtil.h"
#import "Utils.h"


#define SECTION_COUNT 2
#define SECTION_DETAIL 0
#define SECTION_ATTACHMENT 1

#define ROW_PROJECT 0
#define ROW_DUE_DATE 1
#define ROW_FLAG 2

@interface TaskViewController ()

@end

@implementation TaskViewController

@synthesize isEdit, taskId, editButton, recordAudioButton;

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

    self.navigationItem.title = @"New Task";
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    if (taskId) {
        NSLog(@"edit task: %d", taskId);
        task = [Task find:taskId];
        attaches = [[Attach findAll:taskId] mutableCopy];
    } else { 
        NSLog(@"new task");
        task = [[Task alloc] init];
        task.rowid = [Task create:task];
        NSString *relativePath = [NSString stringWithFormat:@"/files/tasks/%d", task.rowid];
        [FileUtil makeFilePath:relativePath];
        attaches = [NSMutableArray array];
    }
    
    [self updateTableViewHeaderWithHeight:0];
    [self updateTableFooterView];
    

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)hideKeyboard 
{
    [titleTextView resignFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        return 3;
    } else if (section == SECTION_ATTACHMENT) {
        return [attaches count];
    } else {
        return 0;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_ATTACHMENT) {
        return 44;
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
        [titleLabel setFrame:CGRectMake(13, 3, 200, 31)];
        [titleLabel setBackgroundColor:[tableView backgroundColor]];
        [headerView addSubview:titleLabel];
        
        if (!audioRecorder.recording && !audioPlayer.playing) {
            if ([attaches count] > 0) {
                editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [editButton setTitle:@"Edit" forState:UIControlStateNormal];
                [editButton setFrame:CGRectMake(250, 3, 50, 31)];
                [editButton setBackgroundColor:[tableView backgroundColor]];
                [editButton addTarget:self action:@selector(editAttach:) forControlEvents:UIControlEventTouchUpInside];
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
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"project";
                        UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(198.0, 9.0, 94.0, 27.0)];
                        topicLabel.text = @"None";
                        topicLabel.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:topicLabel];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    return cell;
                    break;
                }
                case 1: 
                {
                    NSString *CellIdentifier = @"CELL_DETAIL_DUE";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"due";
                        UITextField *dueTextField = [[UITextField alloc] initWithFrame:CGRectMake(198.0, 9.0, 94.0, 27.0)];
                        dueTextField.text = @"None";
                        
                        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
                        datePicker.datePickerMode = UIDatePickerModeDate;
                        //[datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
                        datePicker.tag = indexPath.row;
                        dueTextField.inputView = datePicker;

                        [cell.contentView addSubview:dueTextField];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    return cell;
                    break;
                }
                case 2: 
                {
                    NSString *CellIdentifier = @"CELL_DETAIL_FLAG";
                    PSLabelSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[PSLabelSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    }
                    // Configure the cell...
                    cell.textLabel.text = @"flag";
                    [cell.switcher addTarget:self action:@selector(flagSwitchDidChange) forControlEvents:UIControlEventValueChanged];

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
                if ([attach.audioStatus isEqualToString:@"playing"] || [attach.audioStatus isEqualToString:@"recording"]) {
                    meterView = [[AVMeterView alloc] initWithFrame:CGRectMake(3,  3, 200, 27)];
                    meterView.audioPlayer = audioPlayer;
                    meterView.audioRecorder = audioRecorder;
                    [meterView startUpdating];
                    [cell.contentView addSubview:meterView];
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ created at %@", attach.type, attach.created];
                }
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Picture taken %@", attach.created];
                UIImage *image = [UIImage imageWithContentsOfFile: [attach getPath]];
                NSLog(@"cell attach path: %@",[attach getPath]);
                cell.imageView.image = [Utils resizeImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(32, 32)];
            }
            return cell;
            break;   
        }
        default:
            break;
    }
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    if (indexPath.section == SECTION_DETAIL && indexPath.row == ROW_PROJECT) {
        ProjectSelectorController *projectSelectorController = [[ProjectSelectorController alloc] initWithNibName:@"ProjectSelectorController" bundle:nil];
        [self.navigationController pushViewController:projectSelectorController animated:YES];
    } else if (indexPath.section == SECTION_ATTACHMENT) {
        Attach *attach = [attaches objectAtIndex:indexPath.row];
        if ([attach.type isEqualToString:@"Audio"]) {
            [self playAudio: attach];
        } else {
            ImageViewController *imageViewController = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
            imageViewController.imagePath = [attach getPath];
            [self.navigationController pushViewController:imageViewController animated:YES];
        }
    }
}


#pragma mark - Table view actions

- (void)save 
{
    //todo: save action
	    
    if (isEdit) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        //[self.delegate questionAddViewController:self didAddQuestion:question];
    }
}

- (void)cancel 
{
	if (isEdit) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        //save draft ?
    }
}

- (void)showDetail 
{
    NSLog(@"show detail");
    NoteViewController *noteViewController = [[NoteViewController alloc]initWithNibName:@"NoteViewController" bundle:nil];
    [self.navigationController pushViewController:noteViewController animated:YES];
}

- (void)takePhoto
{
    NSLog(@"take photo");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
}

- (void)pickPhoto 
{
    NSLog(@"pick photo");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - Attach Actions
- (void)editAttach
{
    NSLog(@"Edit Attach");
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
    
    if (audioStatus) {
        attach.audioStatus = audioStatus;
    }
    
    attach.rowid = [Attach create:attach];
    return attach;
}

- (void)removeAttach: (Attach *)attach 
{
    [Attach remove:attach.rowid];
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo 
{
    NSString *imageName = [NSString stringWithFormat:@"%d.JPG", (long)[[NSDate date] timeIntervalSince1970]];
    Attach *attach = [self addAttach:imageName type:@"Photo" audioStatus:nil];
    
    NSData *imageData = UIImagePNGRepresentation(image);
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
                                    [NSNumber numberWithInt:16], 
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2], 
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0], 
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
}
- (void)recordAudio 
{
    NSLog(@"record audio");
    
    NSString *soundFileName = [NSString stringWithFormat:@"%d.caf", (long)[[NSDate date] timeIntervalSince1970]];
    Attach *attach = [self addAttach:soundFileName type:@"Audio" audioStatus:@"recording"];
    [self prepareAudio: [attach getPath]];
    if (!audioRecorder.recording) {
        [audioRecorder record];
    }
    
    [self updateRecordAudioButton];
    [attaches addObject:attach];
    [self.tableView reloadData];
}

- (void)stopAudio 
{
    NSLog(@"stop audio");
    //[meterView stopUpdating];
    meterView.audioPlayer = nil;
    meterView.audioRecorder = nil;
    
    if (audioRecorder.recording) {
        NSLog(@"stop audioRecorder");
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        NSLog(@"stop audioPlayer");
        [audioPlayer stop];
    }
    NSLog(@"before stop all");
    [self stopAll];
    NSLog(@"after stop all");
}

- (void)stopAll 
{
    for (Attach *attach in attaches) {
        attach.audioStatus = @"stop";
    }
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
    [self.tableView reloadData];
}

#pragma mark - Audio Player&Recorder Delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying");
    [recordAudioButton setTitle:@"Record Audio" forState:UIControlStateNormal];
    [self stopAll];
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player 
                                error:(NSError *)error {
    NSLog(@"Decode Error occurred: audioPlayerDecodeErrorDidOccur");
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder 
                          successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording");
    [self stopAll];
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

#pragma mark - TableView Header & Footer
- (void)updateTableViewHeaderWithHeight:(float)height
{
    if (height == 0) {
        height = 44;
    }
    if (taskViewHeaderContainer == nil) {
        taskViewHeaderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
        
        ToggleImageControl *statusControl = [[ToggleImageControl alloc] initWithFrame: CGRectMake(20, 10, 24, 24)];
        [taskViewHeaderContainer addSubview:statusControl];
        
        titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(60, 4, 200, 24)];
        [titleTextView setMinNumberOfLines : 1];
        [titleTextView setMaxNumberOfLines : 3];
        titleTextView.returnKeyType = UIReturnKeyDone;
        titleTextView.font = [UIFont boldSystemFontOfSize:15.0f];
        titleTextView.delegate = self;
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
        taskViewHeaderContainer.frame = CGRectMake(0, 0, 320, height + 17);
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
    [self updateRecordAudioButton];
    
    [footerView addSubview:recordAudioButton];
    NSLog(@"record audio button init");
    [self.tableView setTableFooterView:footerView];
}

- (void)updateRecordAudioButton
{
    if (audioRecorder.recording || audioPlayer.playing) {
        [recordAudioButton setTitle:@"Stop" forState:UIControlStateNormal];
        [recordAudioButton addTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [recordAudioButton setTitle:@"Record Audio" forState:UIControlStateNormal];
        [recordAudioButton addTarget:self action:@selector(recordAudio) forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
