//
//  NUFollowingVC.m
//  YHRouter
//
//  Created by 吴云海 on 2018/3/21.
//  Copyright © 2018年 吴云海. All rights reserved.
//

#import "NUFollowingVC.h"

@interface NUFollowingVC ()

@end



@implementation NUFollowingVC

-(instancetype)init {
    if ((self = [super init])) {
        NSLog(@"NUFollowingVC");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"xxxx");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIViewController *)instanceWithMatcher:(YHRouterMatcher *)matcher {
    NSLog(@"(UIViewController *)instanceWithMatcher:(YHRouterMatcher *)matcher");
    return nil;
}

@end
