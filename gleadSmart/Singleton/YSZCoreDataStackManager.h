//
//  YSZCoreDataStackManager.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//
//  改用FMDB，这个不用了

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

@interface YSZCoreDataStackManager : NSObject

+ (YSZCoreDataStackManager *)shareInstance;

///@brief 管理上下文
@property (strong, nonatomic) NSManagedObjectContext *managedContext;
///@brief 模型对象
@property (strong, nonatomic) NSManagedObjectModel *managedModel;
///@brief 存储调度器
@property (strong, nonatomic) NSPersistentStoreCoordinator *managedDinator;

@end

NS_ASSUME_NONNULL_END
