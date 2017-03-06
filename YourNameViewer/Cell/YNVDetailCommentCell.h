//
//  YNVDetailCommentCell.h
//  YourNameViewer
//
//  Created by 노재원 on 2017. 3. 3..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNVDetailCommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *commenterLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
