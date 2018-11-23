//
//  House+CoreDataProperties.m
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "House+CoreDataProperties.h"

@implementation House (CoreDataProperties)

+ (NSFetchRequest<House *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"House"];
}

@dynamic houseUid;
@dynamic name;
@dynamic lon;
@dynamic lat;
@dynamic mac;
@dynamic userId;
@dynamic auth;

@end
