//
//  Room+CoreDataProperties.m
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "Room+CoreDataProperties.h"

@implementation Room (CoreDataProperties)

+ (NSFetchRequest<Room *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Room"];
}

@dynamic roomUid;
@dynamic houseUid;
@dynamic name;

@end
