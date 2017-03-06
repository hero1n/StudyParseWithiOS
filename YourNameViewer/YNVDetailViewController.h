//
//  YNVDetailViewController.h
//  YourNameViewer
//
//  Created by 노재원 on 2017. 2. 27..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YNVListData.h"

@interface YNVDetailViewController : UIViewController

@property (strong, nonatomic) YNVListData *listData;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
