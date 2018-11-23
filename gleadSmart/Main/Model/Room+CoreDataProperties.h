//
//  Room+CoreDataProperties.h
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "Room+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Room (CoreDataProperties)

+ (NSFetchRequest<Room *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *roomUid;
@property (nullable, nonatomic, copy) NSString *houseUid;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
