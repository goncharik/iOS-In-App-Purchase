//
//  ZTStoreManager.m
//  iOS In-App Purchase
//
//  Created by Zhenya Tulusha on 17.11.10.
//  Copyright 2010 DIMALEX. All rights reserved.
//

#import "ZTStoreManager.h"

@implementation ZTStoreManager

@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;

static NSString *productId = @"<your_product_id";
									 
static __weak id<ZTStoreKitDelegate> _delegate;

static ZTStoreManager* _sharedStoreManager = nil; 

+ (ZTStoreManager *)sharedManager
{
    @synchronized(self)
    {
        if (_sharedStoreManager == nil)
        {
            _sharedStoreManager = [[self alloc] init];
        }
    }
    
    return(_sharedStoreManager);
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.purchasableObjects = [[NSMutableArray alloc] init];
        
        self.storeObserver = [[ZTStoreObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self.storeObserver];
    }
    
    return self;
}

- (void)dealloc {
	
	[_purchasableObjects release];
	[_storeObserver release];
	
	[_sharedStoreManager release];
	[super dealloc];
}

+ (id)delegate {
	
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
	
    _delegate = newDelegate;	
}

#pragma mark -
#pragma mark main Purchsing functional

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"invalid products: %@", response.invalidProductIdentifiers);
	[self.purchasableObjects addObjectsFromArray:response.products];
	// populate UI
	if ([response.invalidProductIdentifiers count] == 0)
	{
        SKProduct* purchasebleProduct = nil;
		for (SKProduct *product in self.purchasableObjects)
        {
            if ([prodId isEqualToString:[product productIdentifier]])
            {
                purchasebleProduct = product;
            }
            NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
                  [[product price] doubleValue], [product productIdentifier]);
        }
        if (purchasebleProduct != nil)
        {
            SKPayment *payment = [SKPayment paymentWithProduct:purchasebleProduct];
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
	
	[request autorelease];
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
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
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
