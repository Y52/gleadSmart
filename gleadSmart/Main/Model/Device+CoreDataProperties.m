//
//  Device+CoreDataProperties.m
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "Device+CoreDataProperties.h"

@implementation Device (CoreDataProperties)

+ (NSFetchRequest<Device *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Device"];
}

@dynamic mac;
@dynamic roomUid;
@dynamic houseUid;

@end
