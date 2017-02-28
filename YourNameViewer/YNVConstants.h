//
//  YNVConstants.h
//  YourNameViewer
//
//  Created by 노재원 on 2017. 2. 27..
//  Copyright © 2017년 heroin. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef YNVConstants_h
#define YNVConstants_h
#ifdef DEBUG
#define NSLog( s, ... ) NSLog( @"%d Line, %s :: %@", __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog( s, ... )
#endif

#define GALLERY_END_POINT @"http://gall.dcinside.com"
#define GALLERY_MAIN_LIST_URL [GALLERY_END_POINT stringByAppendingString:@"/board/lists?id=yourname"]

#endif /* YNVConstant_h */

@interface YNVConstants : NSObject

@end
