//
//  VideosTableViewController.m
//  M9Dev
//
//  Created by MingLQ on 2014-08-14.
//  Copyright (c) 2014年 iwill. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "VideosTableViewController.h"

@interface VideosTableViewController ()

@end

@implementation VideosTableViewController {
    NSMutableArray *videos;
    JSContext *context;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        videos = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [videos count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    return cell;
}
*/

@end
