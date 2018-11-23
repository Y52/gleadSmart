//
//  House+CoreDataProperties.h
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "House+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface House (CoreDataProperties)

+ (NSFetchRequest<House *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *houseUid;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) float lon;
@property (nonatomic) float lat;
@property (nullable, nonatomic, copy) NSString *mac;
@property (nullable, nonatomic, copy) NSString *userId;
@property (nonatomic) int16_t auth;

@end

NS_ASSUME_NONNULL_END
