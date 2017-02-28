//
//  YNVDetailViewController.h
//  YourNameViewer
//
//  Created by 노재원 on 2017. 2. 27..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNVDetailViewController : UIViewController

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *postLinkString;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
