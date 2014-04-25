//
//  DownloadZipController.m
//  DrupalCMS
//
//  Created by Emma Smith on 24/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "DownloadZipController.h"
#import "AFNetworking.h"
#import "ZipArchive.h"
#import "NodesTableViewController.h"

@interface DownloadZipController () {
    
    NSString *drupalDownloadURL;
    NSNumber *nodequeueID;
    NSString *documentsDirectory;
}

#define  DRUPAL_URL @"http://cmstest.digitallabsmmu.com/contentpackagerjson/"
#define ZIP_FILE_FINISHED_DOWNLOAD @"ContentZipFileFinishedDownload"

@end

@implementation DownloadZipController

-(id) init
{
    self = [super init];
    if (self){`
        
        //TODO: this will be called from somewhere
        nodequeueID = @1;
        
        //url to download the drupal db info for a particular nodequeue as json
        drupalDownloadURL = [NSString stringWithFormat:@"%@%@", DRUPAL_URL, nodequeueID];
        documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    }
    return self;
}

#pragma mark - Accessing and downloading of zip file from Drupal

/*
 * Retrieves the version and path for the content of a particular nodequeueid from Drupal
 */
-(void)getVersionPathFromDrupal
{
    NSURL *url = [NSURL URLWithString:drupalDownloadURL];
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
            
            //Check downloading, unzipping, copying and deleting was successful before amending the version number in user defaults
            if ([self downloadZip:downloadUrl]){
                
                [self saveVersionToUserDefaults: newVersion];
                
                //Post a notification and pass the nodequeueID
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:nodequeueID, @"nodequeueID", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZIP_FILE_FINISHED_DOWNLOAD object:self userInfo:userInfo];
                
                NSLog(@"Download, unzipping, copying, deleting process complete");
            } else {
                NSLog(@"Download, unzipping, copying, deleting process unsuccessful");
            }
            
        } else {
            
            NSLog(@"Current version is latest version. No new content.");
            NodesTableViewController *nodesTableViewController = [[NodesTableViewController alloc] init];
            [nodesTableViewController retrieveAndReloadNodes:nodequeueID];
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"The error was: %@", error);
                                         //If passed a nodequeueid that is not in the Drupal db then will hit here
                                         NSLog(@"This could be because there is not a db entry in the Drupal db for the nodequeue id: %@", nodequeueID);
                                     }];
    [operation start];
}

/*
 * Save the version number for a particular nodequeue id in user defaults
 */
-(void)saveVersionToUserDefaults:(NSNumber *)version
{
    NSString *key = [NSString stringWithFormat:@"%@", nodequeueID];
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
    NSString *key = [NSString stringWithFormat:@"%@", nodequeueID];
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
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@", @"download_nqid_", nodequeueID, @".zip"]];
    [data writeToFile:outputPath atomically:YES];
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    NSString *zipDirectory = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/download_nqid_"], nodequeueID, @"/"];
    
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
    NSString *currentPath = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/download_nqid_"], nodequeueID, @"/"];
    //copying to this directory as this will be the name to overwrite if content is already on the phone to begin with
    NSString *newPath = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/content_nqid_"], nodequeueID, @"/"];
    
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