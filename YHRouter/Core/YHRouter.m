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


- (UIViewController *)handleAndPushVCWithURL:(NSString *)url injectedQueryParam:(NSDictionary *)queryParam WithNav:(UINavigationController *)navigationController AndAnimated:(BOOL)animated {
    UIViewController * pointVC = [self handleWithURL:url injectedQueryParam:queryParam];
    if (navigationController) {
        [navigationController pushViewController:pointVC animated:animated];
    } else {
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:pointVC animated:animated completion:nil];
    }
    return pointVC;
}

- (UIViewController *)handleWithURL:(NSString *)url injectedQueryParam:(NSDictionary *)queryParam {
    NSURL * validUrl;
    if ([NSURL URLWithString:url]) {
        validUrl = [NSURL URLWithString:url];
    } else if ([NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]]) {
        validUrl = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    }
    
    if ([validUrl.scheme containsString:@"nestia"]) {
        return [self decodeMatherRoutableWithURL:validUrl injectedQueryParam:queryParam];
    }
    
    return nil;
}

- (UIViewController *)decodeMatherRoutableWithURL:(NSURL *)url injectedQueryParam:(NSDictionary *)queryParam {
    UIViewController *hostvc = [self handleWithHost:[_hosts objectForKey:url.host] WithHostName:url.host WithPath:url.path WithURL:url injectQueryParam:queryParam];
    if (hostvc) {
        return hostvc;
    }
    UIViewController *mainvc = [self handleWithHost:_mainHost WithHostName:url.host WithPath:url.path WithURL:url injectQueryParam:queryParam];
    if (mainvc) {
        return mainvc;
    }
    return nil;
}

- (UIViewController *)handleWithHost:(YHRouterHost *)host WithHostName:(NSString *)hostName WithPath:(NSString *)path WithURL:(NSURL *)url injectQueryParam:(NSDictionary *)queryParam {
    
    for (YHRouterMatcher *matcher in host.pathsRegex) {
        NSString *scheme = [NSString stringWithFormat:@"%@%@",hostName,path];
        NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",matcher.regex];
        if ([carTest evaluateWithObject:scheme]) {
            return [self handleWithMatcher:matcher WithBundleName:host.bundleName withUrl:url injectedQueryParam:queryParam];
        }
    }
    return nil;
}


- (UIViewController *)handleWithMatcher:(YHRouterMatcher *)matcher WithBundleName:(NSString *)bundleName withUrl:(NSURL *)url injectedQueryParam:(NSDictionary *)quertParam {
    if (matcher.className) {
        
        NSArray *arr = [bundleName componentsSeparatedByString:@"."];
        NSBundle *bundle = arr.count > 1 ? [NSBundle bundleWithIdentifier:bundleName] : [YHRouterUtil.sharedRouterUtil getBundleWithName:bundleName];
        
        id zlass = [bundle classNamed:matcher.className];
        UIViewController * viewController = [[zlass alloc] init];
        if (viewController) {
            if ([viewController respondsToSelector:@selector(instanceWithEntity:)]) {
                
                YHRoterEntity * entity = [self parseWithURL:url andMatcher:matcher];
                UIViewController *vc =  [viewController performSelector:@selector(instanceWithEntity:) withObject:entity];
                return vc;
            }
        }
    }
    return nil;
}

- (YHRoterEntity *)parseWithURL:(NSURL *)url andMatcher:(YHRouterMatcher *)matcher {
    YHRoterEntity * entity = [[YHRoterEntity alloc] init];
    entity.rawUrl = url;
    entity.regex = matcher.regex;
    NSMutableDictionary *pathParameter = [NSMutableDictionary dictionary];
    if (matcher.pathIndice.count > 0) {
        NSArray *array = [url.path componentsSeparatedByString:@"/"];
        [matcher.pathIndice enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [pathParameter setValue:[array objectAtIndex:[(NSNumber *)obj integerValue]] forKey:key];
        }];
    }
    entity.pathParameter = pathParameter;
    
    NSMutableDictionary * queryParameter = [NSMutableDictionary dictionary];
    NSArray * keyValues = [url.query componentsSeparatedByString:@"&"];
    if (keyValues.count > 0) {
        for (NSString *wait in keyValues) {
            NSArray *array = [wait componentsSeparatedByString:@"="];
            if (array.count > 0) {
                NSString *value = [array objectAtIndex:1];
                NSString *key = [array objectAtIndex:0];
                [queryParameter setValue:value forKey:key];
            }
        }
    }
    entity.queryParameter = queryParameter;
    return entity;
}


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}
@end
