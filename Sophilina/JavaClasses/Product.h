#import "Data.h"
#import "ProductInfo.h"
#import "ProductLocation.h"
#import "Contact.h"

@interface Product : Data

@property(strong, nonatomic) NSString* userId;
@property(strong, nonatomic) ProductInfo* info;
@property(strong, nonatomic) ProductLocation* location;
@property(strong, nonatomic) NSMutableArray* imgs;
@property(strong, nonatomic) NSString* status;
@property(strong, nonatomic) Contact* contact;
@property(strong, nonatomic) NSString* id;
@property(strong, nonatomic) NSNumber* version;
@property(strong, nonatomic) NSNumber* created;
@property(strong, nonatomic) NSNumber* updated;

@end
