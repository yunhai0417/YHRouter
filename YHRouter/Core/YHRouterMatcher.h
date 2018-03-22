//
//  YHRouterMatcher.h
//  YHRouter
//
//  Created by 吴云海 on 2018/3/21.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YHRouterMatcher;

@interface YHRouterHost : NSObject
@property(copy, nonatomic) NSString *name;
@property(copy, nonatomic) NSString *bundleName;
@property(strong, nonatomic) NSMutableArray <YHRouterMatcher *> *pathsRegex;
- (instancetype)initWithName:(NSString *)name AndBundleName:(NSString *)bundleName;

@end

@interface YHRouterMatcher : NSObject
@property(copy, nonatomic) NSString *regex;
@property(copy, nonatomic) NSString *className;
@property(copy, nonatomic) NSDictionary <NSString *, NSNumber *> *pathIndice;

- (instancetype)initWithRegex:(NSString *)regex WithClassName:(NSString *)className WithPathIndice:(NSDictionary *) pathIndice;

@end

@interface YHRoterEntity : NSObject
@property(strong, nonatomic) NSURL *rawUrl;
@property(copy, nonatomic) NSString *regex;
@property(copy, nonatomic) NSDictionary <NSString *,NSString *> *pathParameter;
@property(copy, nonatomic) NSDictionary <NSString *,NSString *> *queryParameter;

@end
