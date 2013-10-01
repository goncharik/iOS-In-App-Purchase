//
//  ETStoreManager.m
//  iOS In-App Purchase
//
//  Created by Eugene Tulusha on 17.11.10.
//  Copyright 2013 Tulusha.com. All rights reserved.
//

#import "ETStoreManager.h"

@implementation ETStoreManager

@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;
									 
static __weak id<ETStoreKitDelegate> _delegate;

+ (ETStoreManager *)sharedManager
{
    static ETStoreManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [ETStoreManager new];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.purchasableObjects = [[NSMutableArray alloc] init];
        
        self.storeObserver = [[ETStoreObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self.storeObserver];
    }
    
    return self;
}

- (void)dealloc
{
	_purchasableObjects = nil;
	_storeObserver = nil;
}

+ (id)delegate {
	
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
	
    _delegate = newDelegate;	
}

#pragma mark -
#pragma mark main Purchasing functional

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"invalid products: %@", response.invalidProductIdentifiers);
	[self.purchasableObjects addObjectsFromArray:response.products];
	// populate UI
	if ([response.invalidProductIdentifiers count] == 0)
	{
        SKProduct*purchasableProduct = nil;
		for (SKProduct *product in self.purchasableObjects)
        {
            if ([prodId isEqualToString:[product productIdentifier]])
            {
                purchasableProduct = product;
            }
            NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
                  [[product price] doubleValue], [product productIdentifier]);
        }
        if (purchasableProduct != nil)
        {
            SKPayment *payment = [SKPayment paymentWithProduct:purchasableProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
		else
        {
            isPurchasing = NO;
            if ([_delegate respondsToSelector:@selector(productNotPurchased:)])
            {
                [_delegate productNotPurchased:@"Sorry \nThis product isn't available in AppStore yet."];
            }
        }
	}
    else
    {
        isPurchasing = NO;
        if ([_delegate respondsToSelector:@selector(productNotPurchased:)])
        {
            [_delegate productNotPurchased:@"Sorry \nThis product isn't available in AppStore yet."];
        }
    }
}

- (void) buyFeature:(NSString*) featureId
{	
    if (!isPurchasing)
    {
        if ([SKPaymentQueue canMakePayments])
        {
            NSLog(@"going to make request for check availability of product...");
            SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
                                         [NSSet setWithObjects: featureId, nil]];
            request.delegate = self;
            [request start];
            
            isPurchasing = YES;
            prodId = featureId;
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(productNotPurchased:)])
            {
                [_delegate productNotPurchased:@"You are not authorized to purchase from AppStore"];
            }
        }
    }
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    isPurchasing = NO;
	NSString *messageToBeShown = [NSString stringWithFormat:NSLocalizedString(@"Reason: %@, You can try: %@", @""), [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to complete your purchase", @"") message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
    if ([_delegate respondsToSelector:@selector(productNotPurchased:)])
    {
        [_delegate productNotPurchased:nil];
    }
}


//Saving info about purchased items
-(void) provideContent: (NSString*) productIdentifier transactionReceipt:(NSString*)receipt
{
    isPurchasing = NO;
        
	if ([_delegate respondsToSelector:@selector(productPurchased:withReceipt:)])
    {
        [_delegate productPurchased:productIdentifier withReceipt:receipt];
    }
}

- (void) restorePreviousTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) transactionCanceled: (SKPaymentTransaction *)transaction
{
	isPurchasing = NO;
	if ([_delegate respondsToSelector:@selector(productNotPurchased:)])
    {
        [_delegate productNotPurchased:@"Your transaction was canceled."];
    }	
}

@end
