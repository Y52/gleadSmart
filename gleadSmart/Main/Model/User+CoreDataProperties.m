//
//  User+CoreDataProperties.m
//  
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"User"];
}

@dynamic userId;
@dynamic mobile;
@dynamic password;

@end
