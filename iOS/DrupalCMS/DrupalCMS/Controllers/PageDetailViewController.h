//
//  PageDetailViewController.h
//  DrupalCMS
//
//  Created by Emma Smith on 08/05/2014.
//  Copyright (c) 2014 mmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface PageDetailViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

//@property NSString *titleText;
//@property NSString *contentText;
@property Node *node;
@property NSInteger pageIndex;

@end
