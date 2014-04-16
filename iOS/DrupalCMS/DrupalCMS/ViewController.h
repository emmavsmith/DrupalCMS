//
//  ViewController.h
//  DrupalCMS
//
//  Created by Emma Smith on 15/04/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {

    NSString *urlString;
    NSNumber *nodequeueid;
    NSString *documentsDirectory;
}

-(void)getVersionPath;
-(void)downloadZip:(NSString *)downloadUrl;
-(void)copyAndDeleteFiles:(NSString *)outputPath;

@end
