//
//  DownloadZipController.m
//  DrupalCMS
//
//  Created by Emma Smith on 24/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "ContentManager.h"
#import "AFNetworking.h"
#import "ZipArchive.h"
#import "NodesTableViewController.h"
#import "NodeDataProvider.h"

NSString * const ContentUpdateDidCompleteNotification = @"ContentUpdateDidCompleteNotification";

@interface ContentManager () {
    
    NSString *drupalDownloadURL;
    NSNumber *nodequeueID;
}

#define  DRUPAL_URL @"http://cmstest.digitallabsmmu.com/contentpackagerjson/"

@end

@implementation ContentManager

-(id) init
{
    self = [super init];
    if (self){
        
        //TODO: this will not be hardcoded
        nodequeueID = @1;
        
        //url to download the drupal db info for a particular nodequeue as json
        drupalDownloadURL = [NSString stringWithFormat:@"%@%@", DRUPAL_URL, nodequeueID];
    }
    return self;
}

#pragma mark - Existing Content

-(void)checkExistingContent
{
    NSLog(@"Checking existing content");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //check if there is content in the documents on the phone
    NSString *nodequeuePath = [ContentManager contentPathForNodequeueId:nodequeueID];
    
    if(![fileManager fileExistsAtPath:nodequeuePath]) {
        
        //check if there is content in the bundle issued with app and if there is copy it to documents on phone
        NSString *nodequeueZipPath =[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"content_nqid_%@", nodequeueID] ofType:@"zip"];
        
        if([self unzipZipFileFromPath:nodequeueZipPath toPath:nodequeuePath]) {
            //TODO: this will not be hardcoded
            [self saveToUserDefaultsWithVersion:@1];
        }
    }
}

#pragma mark - Content Update

/*
 * Retrieves the version and path for the content of a particular nodequeueid from Drupal
 */
-(void)checkForUpdate
{
    NSURL *url = [NSURL URLWithString:drupalDownloadURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        
        NSNumber *currentVersion = [self getVersionFromUserDefaults];
        NSNumber *newVersion = [NSNumber numberWithInt:[[responseObject valueForKey:@"version"] intValue]];
        NSComparisonResult versionComparisonResult = [currentVersion compare:newVersion];
        
        if(currentVersion == nil || versionComparisonResult == NSOrderedAscending){
            
            NSString *downloadUrl = [responseObject valueForKey:@"file_path"];
            
            //Check downloading, unzipping, copying and deleting was successful before amending the version number in user defaults
            if ([self downloadZipFromURL:downloadUrl]){
                
                if([self installContentFromZipFile]) {
                
                    [self saveToUserDefaultsWithVersion: newVersion];
                
                    //Post a notification and pass the nodequeueID
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:nodequeueID, @"nodequeueID", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ContentUpdateDidCompleteNotification object:self userInfo:userInfo];
                    
                    NSLog(@"Download, unzipping, copying, deleting process complete");
                } else {
                    NSLog(@"Download, unzipping, copying, deleting process unsuccessful");
                }
            } else {
                NSLog(@"Downloading unsuccessful");
            }
        } else {
            NSLog(@"Current version is latest version. No new content.");
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         //If passed a nodequeueid that is not in the Drupal db then will hit here
                                         NSLog(@"The error was: %@", error);
                                     }];
    [operation start];
}

#pragma mark - User Defaults

/*
 * Save the version number for a particular nodequeue id in user defaults
 */
-(void)saveToUserDefaultsWithVersion:(NSNumber *)version
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

#pragma mark - Zip File

/*
 * Downloads a zip file from a particular URL
 */
-(BOOL)downloadZipFromURL:(NSString *)downloadUrl
{
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL: url];
    NSString *downloadZipFolderFilePath = [[ContentManager downloadPathForNodequeueId:nodequeueID] stringByAppendingPathExtension:@"zip"];
    return [data writeToFile:downloadZipFolderFilePath atomically:YES];
}

-(BOOL) installContentFromZipFile
{
    NSString *downloadFolderFilePath = [ContentManager downloadPathForNodequeueId:nodequeueID];
    NSString *downloadZipFolderFilePath = [downloadFolderFilePath stringByAppendingPathExtension:@"zip"];
    NSString *contentFolderFilePath = [ContentManager contentPathForNodequeueId:nodequeueID];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([self unzipZipFileFromPath:downloadZipFolderFilePath toPath:downloadFolderFilePath]) {
        
        //if a file exists already at the path to copy to then remove it
        if ([fileManager fileExistsAtPath:contentFolderFilePath]) {
            
            [fileManager removeItemAtPath:contentFolderFilePath error:nil];
        }
        
        //perform copy then delete unnecessary files
        if([fileManager copyItemAtPath:downloadFolderFilePath toPath:contentFolderFilePath error:nil]){
            
            if([fileManager removeItemAtPath:downloadZipFolderFilePath error:nil] && [fileManager removeItemAtPath:downloadFolderFilePath error:nil]) {
                
                //unzipping, copying and deleting successful
                return YES;
            }
        }
    }
    //either unzipping, copying or deleting was unsuccessful
    return NO;
}

/*
 * Unzips a zip file from a particular directory
 */
-(BOOL)unzipZipFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    BOOL zipSuccessFlag = NO;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
    if ([zipArchive UnzipOpenFile: fromPath]){
        
        if([zipArchive UnzipFileTo:toPath overWrite: YES]){
            zipSuccessFlag = YES;
            NSLog(@"Unzipping successful");
        } else {
            zipSuccessFlag = NO;
            NSLog(@"Unzipping not successful");
        }
        [zipArchive UnzipCloseFile];
    }
    return zipSuccessFlag;
}

#pragma mark - Paths

+(NSString *)documentsDirectory
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

+(NSString *)contentPathForNodequeueId:(NSNumber *)nodequeueID
{
    return [NSString stringWithFormat:@"%@/content_nqid_%@",[ContentManager documentsDirectory], nodequeueID];
}

+(NSString *)downloadPathForNodequeueId:(NSNumber *)nodequeueID
{
    return [NSString stringWithFormat:@"%@/download_nqid_%@",[ContentManager documentsDirectory], nodequeueID];
}

@end
