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
    
    //urlString = @"http://itunes.apple.com/search?term=harry&country=us&entity=movie";
    
    nodequeueid = 1;
    //url to download the drupal db info for a particular nodequeue as json
    urlString = [NSString stringWithFormat:@"%@%d", @"http://cmstest.digitallabsmmu.com/contentpackagerjson/", nodequeueid];
    
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
                                     }];
    [operation start];
}


/*
 * Downloads and unzips a zip file from a particular URL
 */
-(void)downloadZip:(NSString *)downloadUrl
{
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSData *data = [[NSData alloc] initWithContentsOfURL: url];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d%@", @"content_nqid_", nodequeueid, @".zip"]];
    [data writeToFile:outputPath atomically:YES];
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    NSString *zipDirectory = [NSString stringWithFormat:@"%@%d%@", [documentsDirectory stringByAppendingString:@"/content_nqid_"], nodequeueid, @"/"];
    
    if ([zipArchive UnzipOpenFile: outputPath]){
        BOOL ret = [zipArchive UnzipFileTo:zipDirectory overWrite: YES];
        if (NO == ret){}[zipArchive UnzipCloseFile];
    }
    
    NSLog(@"Download and unzipping complete");
}


@end
