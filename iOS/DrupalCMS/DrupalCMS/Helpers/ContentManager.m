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

@interface ContentManager ()

@property (nonatomic, copy) NSString *drupalDownloadURL;

@end

@implementation ContentManager

-(id) initWithURL:(NSString *) drupalDownloadURLIn
{
    self = [super init];
    if (self){
        self.drupalDownloadURL = drupalDownloadURLIn;
    }
    return self;
}

#pragma mark - Existing Content

-(void)checkExistingContentWithNodequeueID:(NSNumber *)nodequeueID
{
    NSLog(@"Checking existing content for nodequeueid %@", nodequeueID);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //check if there is content in the documents on the phone
    NSString *nodequeuePath = [ContentManager contentPathForNodequeueId:nodequeueID];
    
    if(![fileManager fileExistsAtPath:nodequeuePath]) {
        
        //check if there is content in the bundle issued with app and if there is copy it to documents on phone
        NSString *nodequeueZipPath =[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"content_nqid_%@", nodequeueID] ofType:@"zip"];

        if([self unzipZipFileFromPath:nodequeueZipPath toPath:nodequeuePath]) {
            //TODO: this will not be hardcoded
            [self saveToUserDefaultsWithVersion:@1 WithNodequeueID:nodequeueID];
        }
    }
}

#pragma mark - Content Update

/*
 * Retrieves the version and path for the content of a particular nodequeueid from Drupal
 */
-(void)checkForUpdateWithNodequeueID:(NSNumber *)nodequeueID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.drupalDownloadURL, nodequeueID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *currentVersion = [self getVersionFromUserDefaultsWithNodequeueID:nodequeueID];
        NSNumber *newVersion = [NSNumber numberWithInt:[[responseObject valueForKey:@"version"] intValue]];
        NSComparisonResult versionComparisonResult = [currentVersion compare:newVersion];
        
        if(currentVersion == nil || versionComparisonResult == NSOrderedAscending){
            
            NSString *downloadUrl = [responseObject valueForKey:@"file_path"];
            
            //check content update before amending the version number in user defaults
            if ([self downloadZipFromURL:downloadUrl withNodequeueID:nodequeueID]){
                
                if([self installContentFromZipFileWithNodequeueID:nodequeueID]) {
                
                    [self saveToUserDefaultsWithVersion: newVersion WithNodequeueID:nodequeueID];
                
                    //post a notification and pass the nodequeueID
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:nodequeueID, @"nodequeueID", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ContentUpdateDidCompleteNotification object:self userInfo:userInfo];
                    
                    NSLog(@"Content updated successfully for nodequeueid: %@", nodequeueID);
                } else {
                    NSLog(@"Content update failed for nodequeueid: %@", nodequeueID);
                }
            }
        } else {
            NSLog(@"Current version is latest version. No new content for nodequeueid: %@.", nodequeueID);
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         //if passed a nodequeueid that is not in the Drupal db then will hit here
                                         NSLog(@"Error for nodequeueid: %@. The error was: %@", nodequeueID, error);
                                     }];
    [operation start];
}

#pragma mark - User Defaults

/*
 * Save the version number for a particular nodequeue id in user defaults
 */
-(void)saveToUserDefaultsWithVersion:(NSNumber *)version WithNodequeueID:(NSNumber *)nodequeueID
{
    NSString *key = [NSString stringWithFormat:@"%@", nodequeueID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Setting user defaults successful with version: %@ for nodequeueid: %@", version, nodequeueID);
    [defaults setValue:version forKey:key];
    [defaults synchronize];
}

/*
 * Get the version number for a particular nodequeue id from user defaults
 */
-(NSNumber *)getVersionFromUserDefaultsWithNodequeueID:(NSNumber *)nodequeueID
{
    NSString *key = [NSString stringWithFormat:@"%@", nodequeueID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Retrieving version from NSdefaults successful with version: %@ for nodequeueid: %@", [defaults valueForKey:key], nodequeueID);
    return [defaults valueForKey:key];
}

#pragma mark - Zip File

/*
 * Downloads a zip file from a particular URL
 */
-(BOOL)downloadZipFromURL:(NSString *)downloadUrl withNodequeueID: (NSNumber *)nodequeueID
{
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL: url];
    NSString *downloadZipFolderFilePath = [[ContentManager downloadPathForNodequeueId:nodequeueID] stringByAppendingPathExtension:@"zip"];
    return [data writeToFile:downloadZipFolderFilePath atomically:YES];
}

-(BOOL) installContentFromZipFileWithNodequeueID:(NSNumber *)nodequeueID
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
        } else {
            zipSuccessFlag = NO;
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
