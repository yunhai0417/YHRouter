//
//  YHRouterMatcher.m
//  YHRouter
//
//  Created by 吴云海 on 2018/3/21.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import "YHRouterMatcher.h"

@implementation YHRouterHost
- (instancetype)initWithName:(NSString *)name AndBundleName:(NSString *)bundleName{
    if ((self = [super init])) {
        _name = name;
        _bundleName = bundleName;
        _pathsRegex = [NSMutableArray array];
    }
    return self;
}
@end

@implementation YHRouterMatcher

- (instancetype)initWithRegex:(NSString *)regex WithClassName:(NSString *)className WithPathIndice:(NSDictionary *) pathIndice {
    if ((self = [super init])) {
        _regex = regex;
        _className = className;
        _pathIndice = pathIndice;
    }
    return self;
    
}
@end

@implementation YHRoterEntity

@end
