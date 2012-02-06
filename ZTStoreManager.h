//
//  ZTStoreManager.h
//  iOS In-App Purchase
//
//  Created by Zhenya Tulusha on 17.11.10.
//  Copyright 2010 DIMALEX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ZTStoreObserver.h"

@protocol ZTStoreKitDelegate <NSObject>
@optional
- (void)productPurchased:(NSString *)productId withReceipt:(NSString*)receipt;
- (void)productNotPurchased:(NSString *)message;
@end

@interface ZTStoreManager : NSObject <SKProductsRequestDelegate> {
	
	BOOL isPurchasing;
	NSMutableArray *_purchasableObjects;
	ZTStoreObserver *storeObserver;	
    
    NSString* prodId; 
	
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) ZTStoreObserver *storeObserver;

+ (ZTStoreManager*)sharedManager;

//DELEGATES
+(id)delegate;	
+(void)setDelegate:(id)newDelegate;

- (void) buyFeature:(NSString*) featureId;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
