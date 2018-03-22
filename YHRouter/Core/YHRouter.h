//
//  YHRouter.h
//  YHRouter
//
//  Created by 吴云海 on 2018/3/20.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHRouterMatcher.h"



@protocol YHRoutable <NSObject>
- (UIViewController *)instanceWithEntity:(YHRoterEntity *)entity;
@end

@interface YHRouter : NSObject

/**
 *  Returns global shared Router instance
 *
 *  @return YHRouter global instance
 */
+ (YHRouter *)sharedRouter;


/**
 *  UnAllows to specify instance of YHRouter
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Initialization configuration
 *
 */
- (void)run;



@end
