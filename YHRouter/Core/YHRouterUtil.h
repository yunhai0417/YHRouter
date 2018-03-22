//
//  YHRouterUtil.h
//  YHRouter
//
//  Created by 吴云海 on 2018/3/20.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHRouterUtil : NSObject
/**
 *  Returns global shared Router instance
 *
 *  @return YHRouter global instance
 */
+ (YHRouterUtil *)sharedRouterUtil;


/**
 *  UnAllows to specify instance of YHRouter
 */
- (instancetype)init NS_UNAVAILABLE;


- (NSDictionary *)loadDefaultHostMap;

- (NSDictionary *)loadSchemeFromBundleName:(NSString *)bundleName fromPods:(BOOL)fromPods;

- (NSBundle *)getBundleWithName:(NSString *)bundleName;

@end
