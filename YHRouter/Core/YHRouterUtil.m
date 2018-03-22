//
//  YHRouterUtil.m
//  YHRouter
//
//  Created by 吴云海 on 2018/3/20.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import "YHRouterUtil.h"

static NSString *const schemePlistName = @"Scheme";
static NSString *const bundlePrefix = @"org.cocoapods.";


@interface YHRouterUtil ()

@end

@implementation YHRouterUtil

+ (YHRouterUtil *)sharedRouterUtil {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];        
    });
    return instance;
}

- (NSDictionary *)loadDefaultHostMap {
    
    return [self loadPlistFromBundle:[NSBundle bundleForClass:[YHRouterUtil class]] andName:schemePlistName];
}

- (NSDictionary *)loadPlistFromBundle:(NSBundle *)bundle andName:(NSString *)name {
    
    NSString *path = [bundle pathForResource:name ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

- (NSDictionary *)loadSchemeFromBundleName:(NSString *)bundleName fromPods:(BOOL)fromPods {
    if (fromPods) {
        NSString *theBundleName = [NSString stringWithFormat:@"%@%@",bundlePrefix,bundleName];
        NSString *thePlistName = [NSString stringWithFormat:@"%@%@",bundleName,schemePlistName];
        return [self loadPlistFromBundle:[NSBundle bundleWithIdentifier:theBundleName] andName:thePlistName];
    } else {
        NSString * theBundleNameSuffix = [[bundleName componentsSeparatedByString:@"."] lastObject];
        NSString * name = [NSString stringWithFormat:@"%@%@",theBundleNameSuffix,schemePlistName];
        return [self loadPlistFromBundle:[NSBundle bundleWithIdentifier:bundleName] andName:name];
    }
    return nil;
}

- (NSBundle *)getBundleWithName:(NSString *)bundleName {
    NSString *name = [NSString stringWithFormat:@"%@%@",bundlePrefix,bundleName];
    return [NSBundle bundleWithIdentifier:name];
}
@end
