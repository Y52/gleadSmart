//
//  AddShareController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/18.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WMPageController/WMPageController.h>


NS_ASSUME_NONNULL_BEGIN

@interface AddShareController : WMPageController

@property (nonatomic, strong) HouseModel *house;

@property (nonatomic, strong) NSMutableArray *isSharedDiviceMacList;
@property (nonatomic, strong) SharerModel *sharer;

@end

NS_ASSUME_NONNULL_END
