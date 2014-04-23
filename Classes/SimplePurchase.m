
#import <StoreKit/StoreKit.h>
#import "SimplePurchase.h"
#import "Purchaser.h"

static Purchaser *_purchaser;

@implementation SimplePurchase

+ (void)initialize
{
    _purchaser = [[Purchaser alloc] init];
}

+ (void)addObserverForProduct:(NSString *)productId block:(void(^)(SKPaymentTransaction *transaction))block
{
    [_purchaser addObserverForProduct:productId block:block];
}

+ (void)buyProduct:(NSString *)productId succeeded:(void (^)(SKPaymentTransaction *))succeeded failed:(void (^)(NSError *))block
{
    [_purchaser buyProduct:productId succeeded:succeeded failed:block];
}

@end
