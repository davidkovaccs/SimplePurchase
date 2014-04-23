
#import <StoreKit/StoreKit.h>
#import "Purchaser.h"
#import "ProductCache.h"

@implementation Purchaser
{
    ProductCache *_cache;
    NSMutableDictionary *_observers;
    NSMutableDictionary *_failed_blocks;
    NSMutableDictionary *_succeeded_blocks;
}

- (id)init
{
    if (self = [super init])
    {
        _cache = [[ProductCache alloc] init];
        _observers = [[NSMutableDictionary alloc] init];
        _failed_blocks = [[NSMutableDictionary alloc] init];
        _succeeded_blocks = [[NSMutableDictionary alloc] init];

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

- (void)addObserverForProduct:(NSString *)productId block:(void(^)(SKPaymentTransaction *transaction))block
{
    if (!_observers[productId])
        [_observers setObject:[[NSMutableArray alloc] init] forKey:productId];
    
    NSMutableArray *array = _observers[productId];
    [array addObject:block];
}

- (void)buyProduct:(NSString *)productId succeeded:(void (^)(SKPaymentTransaction *))succeeded failed:(void (^)(NSError *))block
{
    [_cache loadProduct:productId block:^(SKProduct *product, NSError *error)
     {
         if (error)
             block(error);
         else
         {
             [_failed_blocks setObject:block forKey:productId];
             [_succeeded_blocks setObject:succeeded forKey:productId];
             [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
         }
     }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *t in transactions)
    {
        if (![self transactionIsComplete:t])
            continue;
        
        void (^failed_block)(NSError *) = _failed_blocks[t.payment.productIdentifier];
        void (^succeeded_block)(SKPaymentTransaction *) = _succeeded_blocks[t.payment.productIdentifier];

        if (failed_block && t.error)
        {
            failed_block(t.error);
        }
        else if (succeeded_block)
        {
            succeeded_block(t);
        }
        
        [_failed_blocks removeObjectForKey:t.payment.productIdentifier];
        [_succeeded_blocks removeObjectForKey:t.payment.productIdentifier];
        
        if ([self transactionIsSuccess:t])
            [self notifyObserversForProduct:t.payment.productIdentifier transaction:t];
        
        [[SKPaymentQueue defaultQueue] finishTransaction:t];
    }
}

- (BOOL)transactionIsComplete:(SKPaymentTransaction *)transaction
{
    return
        transaction.transactionState == SKPaymentTransactionStatePurchased ||
        transaction.transactionState == SKPaymentTransactionStateRestored ||
        transaction.transactionState == SKPaymentTransactionStateFailed;
}

- (BOOL)transactionIsSuccess:(SKPaymentTransaction *)transaction
{
    return
        transaction.transactionState == SKPaymentTransactionStatePurchased ||
        transaction.transactionState == SKPaymentTransactionStateRestored;
}

- (void)notifyObserversForProduct:(NSString *)productId transaction:(SKPaymentTransaction *)transaction
{
    for (void(^block)(SKPaymentTransaction *) in _observers[productId])
        block(transaction);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
}

@end
