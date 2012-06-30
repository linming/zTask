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

#define SECTION_COUNT 2
#define SECTION_DETAIL 0
#define SECTION_ATTACHMENT 1

#define ROW_PROJECT 0
#define ROW_DUE_DATE 1
#define ROW_FLAG 2

@interface TaskViewController ()

@end

@implementation TaskViewController

@synthesize isEdit, editButton, recordAudioButton;

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
        return 0;
    } else {
        return 0;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_DETAIL) {
        return 54;
    } else if (section == SECTION_ATTACHMENT) {
        return 44;
    } else {
        return 0;
    }
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_DETAIL) {
        UIView *taskViewHeaderContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        
        UIView *taskViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];


        ToggleImageControl *statusControl = [[ToggleImageControl alloc] initWithFrame: CGRectMake(20, 10, 24, 24)];
        [taskViewHeader addSubview:statusControl];
        
        HPGrowingTextView *titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(60, 4, 200, 24)];
        [titleTextView setMinNumberOfLines : 1];
        [titleTextView setMaxNumberOfLines : 3];
        titleTextView.returnKeyType = UIReturnKeyDone;
        titleTextView.font = [UIFont boldSystemFontOfSize:15.0f];
        titleTextView.delegate = self;
        [taskViewHeader addSubview:titleTextView];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure]; 
        detailButton.frame = CGRectMake(285, 5, 29, 31);
        [taskViewHeader addSubview:detailButton];
        
        taskViewHeader.layer.shadowColor = [[UIColor blackColor] CGColor];
        taskViewHeader.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        taskViewHeader.layer.shadowOpacity = 1;
        taskViewHeader.layer.masksToBounds = NO;
        taskViewHeader.layer.borderWidth = 1.0f;
        taskViewHeader.backgroundColor = [UIColor whiteColor];

        [taskViewHeaderContainer addSubview:taskViewHeader];
        return taskViewHeaderContainer;
    } else if (section == SECTION_ATTACHMENT) {
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == SECTION_ATTACHMENT) {
        UIView *footerView  = [[UIView alloc] init];
        
        UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [takePhotoButton setFrame:CGRectMake(10, 3, 145, 44)];
        [takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
        [takePhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:takePhotoButton];
        
        UIButton *pickPhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [pickPhotoButton setFrame:CGRectMake(165, 3, 145, 44)];
        [pickPhotoButton setTitle:@"Pick Photo" forState:UIControlStateNormal];
        [pickPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pickPhotoButton addTarget:self action:@selector(pickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:pickPhotoButton];
        
        recordAudioButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [recordAudioButton setFrame:CGRectMake(87, 53, 146, 44)];
        [recordAudioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (audioRecorder.recording || audioPlayer.playing) {
            [recordAudioButton setTitle:@"Stop" forState:UIControlStateNormal];
            [recordAudioButton addTarget:self action:@selector(stopAudio:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [recordAudioButton setTitle:@"Record Audio" forState:UIControlStateNormal];
            [recordAudioButton addTarget:self action:@selector(recordAudio:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [footerView addSubview:recordAudioButton];
        NSLog(@"record audio button init");
        return footerView;
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
                        [cell.contentView addSubview:topicLabel];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                        UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(198.0, 9.0, 94.0, 27.0)];
                        topicLabel.text = @"None";
                        [cell.contentView addSubview:topicLabel];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    return cell;
                    break;
                }
                case 2: 
                {
                    NSString *CellIdentifier = @"CELL_DETAIL_FLAG";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        cell.textLabel.text = @"flag";
                        UILabel *topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(198.0, 9.0, 94.0, 27.0)];
                        topicLabel.text = @"None";
                        [cell.contentView addSubview:topicLabel];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    return cell;
                    break;
                }
                default:
                    break;
            }
            break;
        case SECTION_ATTACHMENT:
            
            break;   
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
            imageViewController.imagePath = attach.path;
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

- (IBAction)showDetail:(id)sender 
{
    NoteViewController *noteViewController = [[NoteViewController alloc]initWithNibName:@"NoteViewController" bundle:nil];
    [self.navigationController pushViewController:noteViewController animated:YES];
}

- (IBAction)takePhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
}

- (IBAction)pickPhoto:(id)sender 
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - Attach Actions
- (IBAction)editAttach:(id)sender 
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

- (void)addAttach:(NSString *)type path:(NSString *)path audioStatus:(NSString *)audioStatus
{
    Attach *attach = [[Attach alloc] init];
    attach.type = type;
    attach.path = path;
    attach.created = [NSDate date];
    if (audioStatus) {
        attach.audioStatus = audioStatus;
    }
    
    [attaches addObject:attach];
    [self.tableView reloadData];
}

- (void)removeAttach: (Attach *)attach 
{
    [Attach remove:attach.rowid];
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo 
{
    
    NSData* imageData = UIImagePNGRepresentation(image);
    
    // Give a name to the file
    NSString* imageName = [NSString stringWithFormat:@"%d.JPG", (long)[[NSDate date] timeIntervalSince1970]]; 
    
    // Now, we have to find the documents directory so we can save it
    // Note that you might want to save it elsewhere, like the cache directory,
    // or something similar.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
    
    
    NSLog(@"%@", fullPathToFile);
    
    
    [picker dismissModalViewControllerAnimated:YES];
    [self addAttach:@"Photo" path:fullPathToFile audioStatus:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Audio Actions
- (void)prepareAudio: (NSString *)path 
{
    
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
- (IBAction)recordAudio:(id)sender 
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.caf", (long)[[NSDate date] timeIntervalSince1970]]];
    [self addAttach: @"Audio" path:soundFilePath audioStatus:@"recording"];
    [self prepareAudio: soundFilePath];
    if (!audioRecorder.recording) {
        [audioRecorder record];
    }
}

- (IBAction)stopAudio:(id)sender 
{
    NSLog(@"stop audio");
    
    if (audioRecorder.recording) {
        NSLog(@"stop audioRecorder");
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        NSLog(@"stop audioPlayer");
        [audioPlayer stop];
    }
    [self stopAll];
}

- (void)stopAll 
{
    for (Attach *attach in attaches) {
        attach.audioStatus = @"stop";
    }
    [self.tableView reloadData];
}

- (void)playAudio: (Attach *)attach {    
    NSURL *soundFileURL = [NSURL fileURLWithPath:attach.path];
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
    [self.tableView reloadData];
}

@end
