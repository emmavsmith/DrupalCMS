//
//  NodesTableViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 23/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "NodesTableViewController.h"
#import "AFNetworking.h"
#import "ZipArchive.h"
#import "NodeDataProvider.h"
#import "NodesTableViewCell.h"
#import "Node.h"

@interface NodesTableViewController () {
    
    NSString *urlString;
    NSNumber *nodequeueid;
    NSString *documentsDirectory;
}

@property NSMutableArray *nodeObjectsArray;

#define  DRUPAL_URL @"http://cmstest.digitallabsmmu.com/contentpackagerjson/"

@end

@implementation NodesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.nodeObjectsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO this will be called from somewhere
    nodequeueid = @1;
    //url to download the drupal db info for a particular nodequeue as json
    urlString = [NSString stringWithFormat:@"%@%@", DRUPAL_URL, nodequeueid];
    documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    [self getVersionPathFromDrupal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Number of rows in section = %lu", (unsigned long)[_nodeObjectsArray count]);
    return [_nodeObjectsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NodesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodesTableViewCell"];
    
    if (cell == nil) {
        cell = [[NodesTableViewCell alloc] init];
    }
    
    Node *node = [_nodeObjectsArray objectAtIndex:indexPath.row];
    
    cell.nodeTitleLabel.text = node.title;
    //[[plistDestinations objectAtIndex:indexPath.row]objectForKey:@"destination"];
    
    NSLog(@"cell description = %@",[cell description]);
    
    return cell;
}

#pragma mark - Accessing and downloading of zip file from Drupal

/*
 * Retrieves the version and path for the content of a particular nodequeueid from Drupal
 */
-(void)getVersionPathFromDrupal
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        
        NSNumber *currentVersion = [self getVersionFromUserDefaults];
        NSNumber *newVersion = [NSNumber numberWithInt:[[responseObject valueForKey:@"version"] intValue]];
        NSComparisonResult result = [currentVersion compare:newVersion];
        
        if(currentVersion == nil || result == NSOrderedAscending){
            
            NSString *downloadUrl = [responseObject valueForKey:@"file_path"];
            
            //check downloading, unzipping, copying and deleting was successful before amending the version number in user defaults
            if ([self downloadZip:downloadUrl]){
                
                [self saveVersionToUserDefaults: newVersion];
            }
            NSLog(@"Download, unzipping, copying, deleting process complete");
            
            //Retrieve nodes from a nodequeue
            [self retrieveNodequeuesNodes];
            
        } else {
            NSLog(@"Current version is latest version. No new content.");
            NSLog(@"Download, unzipping, copying, deleting process complete");
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"The error was: %@", error);
                                         //TODO If passed a nodequeueid that is not in the Drupal db then will hit here
                                         NSLog(@"This could be because there is not a db entry in the Drupal db for the nodequeue id: %@", nodequeueid);
                                     }];
    [operation start];
}


/*
 * Save the version number for a particular nodequeue id in user defaults
 */
-(void)saveVersionToUserDefaults:(NSNumber *)version
{
    NSString *key = [NSString stringWithFormat:@"%@", nodequeueid];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Setting user defaults successful with version: %@", version);
    [defaults setValue:version forKey:key];
    [defaults synchronize];
}


/*
 * Get the version number for a particular nodequeue id from user defaults
 */
-(NSNumber *)getVersionFromUserDefaults
{
    NSString *key = [NSString stringWithFormat:@"%@", nodequeueid];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Retrieving version from NSdefaults successful with version: %@", [defaults valueForKey:key]);
    return [defaults valueForKey:key];
}

/*
 * Downloads and unzips a zip file from a particular URL
 */
-(BOOL)downloadZip:(NSString *)downloadUrl
{
    BOOL zipSuccessFlag = NO;
    
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL: url];
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@", @"download_nqid_", nodequeueid, @".zip"]];
    [data writeToFile:outputPath atomically:YES];
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    NSString *zipDirectory = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/download_nqid_"], nodequeueid, @"/"];
    
    if ([zipArchive UnzipOpenFile: outputPath]){
        
        if([zipArchive UnzipFileTo:zipDirectory overWrite: YES]){
            zipSuccessFlag = YES;
            NSLog(@"Unzipping successful");
        } else {
            zipSuccessFlag = NO;
            NSLog(@"Unzipping not successful");
        }
        [zipArchive UnzipCloseFile];
    }
    
    if(zipSuccessFlag){
        
        if([self copyAndDeleteFiles:outputPath]){
            return YES;
        }
    }
    return NO;
}


/*
 * Copys downloaded files from the download folder to the permanent content folder
 * Deletes the download zip and unzipped folder as it is no longer needed
 */
-(BOOL)copyAndDeleteFiles:(NSString *)outputPath
{
    NSString *currentPath = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/download_nqid_"], nodequeueid, @"/"];
    //copying to this directory as this will be the name to overwrite if content is already on the phone to begin with
    NSString *newPath = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/content_nqid_"], nodequeueid, @"/"];
    
    if([[NSFileManager defaultManager] copyItemAtPath:currentPath toPath:newPath error:nil]){
        
        NSLog(@"Copying successful");
        
        //delete zip and download folder
        if ([[NSFileManager defaultManager] removeItemAtPath:currentPath error:nil] && [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil]){
            
            NSLog(@"Deleting successful");
            return YES;
        } else {
            NSLog(@"Deleting unsuccessful");
        }
    } else {
        
        NSLog(@"Copying unsuccessful");
        NSLog(@"Deleting unsuccessful");
    }
    return NO;
}

#pragma mark - Nodequeues nodes

/*
 *
 */
-(void)retrieveNodequeuesNodes
{
    NodeDataProvider *nodeDataProvider = [[NodeDataProvider alloc] init];
    [nodeDataProvider retrieveJSONFile:nodequeueid];
    _nodeObjectsArray = nodeDataProvider.nodesArray;
    
    NSLog(@"nodeObjectsArray in NodesTableViewController = %@", _nodeObjectsArray);
    
    [self.tableView reloadData];
}


#pragma mark - Commented out default TableViewController methods

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
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
