//
//  YHRouter.m
//  YHRouter
//
//  Created by 吴云海 on 2018/3/20.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import "YHRouter.h"
#import "YHRouterUtil.h"


@interface YHRouter ()
@property (strong, nonatomic, readwrite) NSMutableDictionary *hosts;
@property (assign, nonatomic, getter = isRegisterScheme) BOOL registerScheme;
@property (strong, nonatomic) YHRouterHost * mainHost;
@end

@implementation YHRouter

+ (YHRouter *)sharedRouter {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (void)run {
    if (self.isRegisterScheme) {
        return;
    }
    self.registerScheme = YES;
    [self registerSchemes];
}

- (void)registerSchemes {
    NSDictionary * theHosts = [YHRouterUtil.sharedRouterUtil loadDefaultHostMap];
    _hosts = [NSMutableDictionary dictionary];
    if (theHosts.count > 0) {
        [theHosts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            YHRouterHost * router = [self createHostWithName:key andBundleName:obj andIsfromPods:YES];
            if (router) {
                [_hosts setValue:router forKey:key];
            }
        }];
    }
    _mainHost = [self createHostWithName:@"NUUserCenterScheme" andBundleName:[[NSBundle mainBundle] bundleIdentifier] andIsfromPods:false];
    
    YHRouterMatcher * temp = [[YHRouterMatcher alloc] initWithRegex:@"^usercenter/following$" WithClassName:@"NUFollowingVC" WithPathIndice:nil];
    [self handleWithMatcher:temp WithBundleName:[[NSBundle mainBundle] bundleIdentifier] withUrl:nil injectedQueryParam:nil];
}

- (YHRouterHost *)createHostWithName:(NSString *)name andBundleName:(NSString *)bundleName andIsfromPods:(BOOL)fromPods {
    YHRouterHost * router = [[YHRouterHost alloc] initWithName:name AndBundleName:bundleName];
    NSDictionary <NSString*, NSString*> *pathdic = [YHRouterUtil.sharedRouterUtil loadSchemeFromBundleName:bundleName fromPods:fromPods];
    if (pathdic.count > 0) {
        NSMutableArray <YHRouterMatcher *> *matchers = [NSMutableArray array];
        [pathdic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSMutableDictionary <NSString *, NSNumber *> *pathIndice = [NSMutableDictionary dictionary];
            
            BOOL withWildCard = NO;
            NSMutableArray <NSString *> *pathComponents = [NSMutableArray arrayWithArray:[key componentsSeparatedByString:@"/"]];
            for (int index = 0; index < pathComponents.count; index++) {
                NSString *str = [pathComponents objectAtIndex:index];
                if ([str hasPrefix:@":"]) {
                    NSString *value = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
                    [pathIndice setValue:[NSNumber numberWithInt:index] forKey:value];
                    [pathComponents replaceObjectAtIndex:index withObject:@"[^/]+"];
                    withWildCard = YES;
                }
            }
            NSString *pattern = [NSString stringWithFormat:@"^%@$",[pathComponents componentsJoinedByString:@"/"]];
            YHRouterMatcher *matcher = [[YHRouterMatcher alloc] initWithRegex:pattern WithClassName:obj WithPathIndice:pathIndice];
            if (withWildCard) {
                [matchers addObject:matcher];
            } else {
                [matchers insertObject:matcher atIndex:0];
            }
        }];
        router.pathsRegex = matchers;
    }
    
    return router;
}


- (UIViewController *)handleWithMatcher:(YHRouterMatcher *)matcher WithBundleName:(NSString *)bundleName withUrl:(NSURL *)url injectedQueryParam:(NSDictionary *)quertParam {
    if (matcher.className) {
        
        NSArray *arr = [bundleName componentsSeparatedByString:@"."];
        NSBundle *bundle = arr.count > 1 ? [NSBundle bundleWithIdentifier:bundleName] : [YHRouterUtil.sharedRouterUtil getBundleWithName:bundleName];
        
        id zlass = [bundle classNamed:matcher.className];
        UIViewController * viewController = [[zlass alloc] init];
        if (viewController) {
            if ([viewController respondsToSelector:@selector(instanceWithEntity:)]) {
                return [viewController performSelector:@selector(instanceWithEntity:) withObject:nil];
            }
        }
    }
    return nil;
}

- (YHRoterEntity *)parseWithURL:(NSURL *)url andMatcher:(YHRouterMatcher *)matcher {
    YHRoterEntity * entity = [[YHRoterEntity alloc] init];
    
    return entity;
}

@end
