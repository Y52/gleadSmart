//
//  Device+CoreDataProperties.h
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "Device+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Device (CoreDataProperties)

+ (NSFetchRequest<Device *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *mac;
@property (nullable, nonatomic, copy) NSString *roomUid;
@property (nullable, nonatomic, copy) NSString *houseUid;

@end

NS_ASSUME_NONNULL_END
