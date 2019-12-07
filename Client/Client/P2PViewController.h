//
//  P2PViewController.h
//  Client
//
//  Created by 珲少 on 2019/11/29.
//  Copyright © 2019 jaki. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface P2PViewController : UIViewController

@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, assign) int server;

@end

NS_ASSUME_NONNULL_END
