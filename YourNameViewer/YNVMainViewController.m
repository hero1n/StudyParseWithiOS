//
//  YNVMainViewController
//  YourNameViewer
//
//  Created by 노재원 on 2017. 2. 27..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import "YNVMainViewController.h"
#import "YNVDetailViewController.h"

// Libraries
#import "TFHpple.h"

// Cell
#import "YNVMainListCell.h"

static NSString *const cellIdentifier = @"mainListCell";

@interface YNVListData : NSObject

@property (strong, nonatomic, nullable) NSString *title;
@property (strong, nonatomic, nullable) NSString *userName;
@property (strong, nonatomic, nullable) NSString *postDateString;
@property (strong, nonatomic, nullable) NSString *postLink;

@end

@implementation YNVListData

@end

@interface YNVMainViewController ()

@property (strong, nonatomic, nonnull) NSMutableArray<NSMutableArray<YNVListData *> *> *dataArray;

@property (strong, nonatomic, nonnull) UIRefreshControl *refreshControl;
@property (strong, nonatomic, nonnull) UIActivityIndicatorView *tableSpinner;

@property NSInteger pageIndex;
@property Boolean isLoading;

@end

@implementation YNVMainViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.pageIndex = 1;
        self.isLoading = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 70.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.tableSpinner.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
    self.tableSpinner.hidesWhenStopped = YES;
    self.tableView.tableFooterView = self.tableSpinner;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self addGalleryList];
}

- (void)refresh {
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    
    [self addGalleryList];
}

- (void)addGalleryList {
    [self.view makeToastActivity:CSToastPositionCenter];
    self.isLoading = YES;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSURL *mainURL = [NSURL URLWithString:[GALLERY_MAIN_LIST_URL stringByAppendingFormat:@"&page=%ld", self.pageIndex]];
        NSData *mainHTMLData = [NSData dataWithContentsOfURL:mainURL];
        
        TFHpple *mainParser = [TFHpple hppleWithHTMLData:mainHTMLData];
        
        NSString *XPathQuery = @"//*[@id='dgn_gallery_left']/div[3]/div[1]/table/tbody/tr";
        NSArray<TFHppleElement *> *parsedArray = [mainParser searchWithXPathQuery:XPathQuery];
        
        NSMutableArray<YNVListData *> *tempDataArray = [NSMutableArray array];
        
        for (TFHppleElement *element in parsedArray) {
            NSLog(@"<<<<<< %@ <> %@ <> %@ >>>>>>>", element.text, element.tagName, element.attributes);
            
            YNVListData *data = [[YNVListData alloc] init];
            
            for (TFHppleElement *childrenElement in element.children) {
                if ([childrenElement.tagName isEqual:@"text"]) {
                    continue;
                }
                
                NSLog(@"<<<<<< %@ <> %@ <> %@ >>>>>>>", childrenElement.content, childrenElement.tagName, childrenElement.attributes);
                
                if ([childrenElement.attributes[@"class"] isEqual:@"t_subject"]) {
                    NSString *hrefLinkString = [childrenElement firstChildWithTagName:@"a"].attributes[@"href"];
                    data.postLink = hrefLinkString;
                    
                    NSLog(@"hihi: %@", childrenElement.raw);
                    data.title = childrenElement.firstChild.text;
                    
                } else if ([childrenElement.attributes[@"class"] isEqual:@"t_writer user_layer"]) {
                    NSString *userName = childrenElement.attributes[@"user_name"];
                    
                    data.userName = userName.length == 0 ? @"" : userName;
                } else if ([childrenElement.attributes[@"class"] isEqual:@"t_date"]) {
                    data.postDateString = [(NSString *)childrenElement.attributes[@"title"] substringWithRange:NSMakeRange(5, 11)];
                }
            }
            
            if (data.title.length != 0 && ![data.userName isEqualToString:@"새초미♡"]) {
                [tempDataArray addObject:data];
            }
        }
        
        [self.dataArray addObject:tempDataArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            [self.view hideToastActivity];
            [self.tableSpinner stopAnimating];
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"페이지 %ld", section + 1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading == YES) {
        return [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    YNVMainListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    YNVListData *listData = self.dataArray[indexPath.section][indexPath.row];
    
    cell.titleLabel.text = listData.title;
    cell.userNameLabel.text = listData.userName;
    cell.postDateLabel.text = listData.postDateString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.dataArray.count - 1 && indexPath.row == self.dataArray[indexPath.section].count - 1) {
        self.pageIndex++;
        [self.tableSpinner startAnimating];
        
        [self addGalleryList];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YNVListData *listData = self.dataArray[indexPath.section][indexPath.row];
    
    YNVDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"YNVDetailViewController"];
    detailViewController.titleString = listData.title;
    detailViewController.postLinkString = listData.postLink;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
