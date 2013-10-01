//
//  ETStoreManager.h
//  iOS In-App Purchase
//
//  Created by Eugene Tulusha on 17.11.10.
//  Copyright 2013 Tulusha.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ETStoreObserver.h"

@protocol ETStoreKitDelegate <NSObject>
@optional
- (void)productPurchased:(NSString *)productId withReceipt:(NSString*)receipt;
- (void)productNotPurchased:(NSString *)message;
@end

@interface ETStoreManager : NSObject <SKProductsRequestDelegate> {
	
	BOOL isPurchasing;
	NSMutableArray *_purchasableObjects;
	ETStoreObserver *storeObserver;
    
    NSString* prodId; 
	
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) ETStoreObserver *storeObserver;

+ (ETStoreManager *)sharedManager;

//DELEGATES
+(id)delegate;	
+(void)setDelegate:(id)newDelegate;

- (void) buyFeature:(NSString*) featureId;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
