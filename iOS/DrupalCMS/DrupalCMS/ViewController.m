//
//  ViewController.m
//  DrupalCMS
//
//  Created by Emma Smith on 15/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/search?term=harry&country=us&entity=movie"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"The error was: %@", error);
                                     }];
    [operation start];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
