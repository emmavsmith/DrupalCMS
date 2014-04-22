//
//  ViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 15/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "ZipArchive.h"
#import "NodeDataProvider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO this will be called from somewhere
    nodequeueid = @1;
    //url to download the drupal db info for a particular nodequeue as json
    urlString = [NSString stringWithFormat:@"%@%@", @"http://cmstest.digitallabsmmu.com/contentpackagerjson/", nodequeueid];
    documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    [self getVersionPathFromDrupal];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
            NSLog(@"Process complete");
            
            NodeDataProvider *nodeDataProvider = [[NodeDataProvider alloc] init];
            [nodeDataProvider retrieveJSONFile:nodequeueid];
            
        } else {
            NSLog(@"Current version is latest version. No new content.");
            NSLog(@"Process complete");
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

@end
