//
//  YSZCoreDataStackManager.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "YSZCoreDataStackManager.h"

static YSZCoreDataStackManager *_instance = nil;
NSString *const dbName = @"gleadSqlit.db";

@implementation YSZCoreDataStackManager

+ (YSZCoreDataStackManager *)shareInstance{
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.managedModel = [self managedModel];
        self.managedDinator = [self managedDinator];
        self.managedContext = [self managedContext];
    }
    return self;
}

#pragma mark - Lazy load
- (NSURL *)getDocumentUrlPath{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)managedContext{
    if (_managedContext != nil) {
        return _managedContext;
    }
    _managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedContext setPersistentStoreCoordinator:self.managedDinator];
    return _managedContext;
}

-(NSManagedObjectModel *)managedModel{
    if (_managedModel != nil) {
        return _managedModel;
    }
    _managedModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedModel;
}

- (NSPersistentStoreCoordinator *)managedDinator{
    if (_managedDinator != nil) {
        return _managedDinator;
    }
    _managedDinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedModel];
    //添加存储器
    /**
     * type:一般使用数据库存储方式NSSQLiteStoreType
     * configuration:配置信息 一般无需配置
     * URL:要保存的文件路径
     * options:参数信息 一般无需设置
     */
    NSURL *url = [[self getDocumentUrlPath] URLByAppendingPathComponent:dbName isDirectory:YES];
    NSError *error;
    if (![_managedDinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        NSLog(@"%@",error);
    }
    
    return _managedDinator;
}

#pragma mark - CoreData Actions
- (void)save{
    [self.managedContext save:nil];
}

@end
