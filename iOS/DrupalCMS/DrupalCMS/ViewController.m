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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nodequeueid = @1;
    //url to download the drupal db info for a particular nodequeue as json
    urlString = [NSString stringWithFormat:@"%@%@", @"http://cmstest.digitallabsmmu.com/contentpackagerjson/", nodequeueid];
    documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    [self getVersionPath];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/* Retrieves the version and path for the content of a particular nodequeueid from Drupal
 *
 */
-(void)getVersionPath
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        
        //check version number here
        
        NSString *downloadUrl = [responseObject valueForKey:@"file_path"];
        [self downloadZip:downloadUrl];
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"The error was: %@", error);
                                         //If passed a nodequeueid that is not in the Drupal db then will hit here
                                         
                                     }];
    [operation start];
}


/*
 * Downloads and unzips a zip file from a particular URL
 */
-(void)downloadZip:(NSString *)downloadUrl
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
        [self copyAndDeleteFiles:outputPath];
    }
}


/*
 *
 */
-(void)copyAndDeleteFiles:(NSString *)outputPath
{
    //copy download folder contents to content folder
    NSString *currentPath = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/download_nqid_"], nodequeueid, @"/"];
    NSString *newPath = [NSString stringWithFormat:@"%@%@%@", [documentsDirectory stringByAppendingString:@"/content_nqid_"], nodequeueid, @"/"];
    
    if([[NSFileManager defaultManager] copyItemAtPath:currentPath toPath:newPath error:nil]){
        
        NSLog(@"Copying successful");
        
        //delete zip and download folder
        [[NSFileManager defaultManager] removeItemAtPath:currentPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
        
        NSLog(@"Deleting successful");
    }
}

@end
