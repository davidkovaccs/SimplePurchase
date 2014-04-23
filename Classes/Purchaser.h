
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface Purchaser : NSObject<SKPaymentTransactionObserver>

- (void)addObserverForProduct:(NSString *)productId block:(void(^)(SKPaymentTransaction *transaction))block;
- (void)buyProduct:(NSString *)productId succeeded:(void (^)(SKPaymentTransaction *))succeeded failed:(void (^)(NSError *))block;

@end
