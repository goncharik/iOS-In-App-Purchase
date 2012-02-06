//
//  ZTStoreObserver.h
//  iOS In-App Purchase
//
//  Created by Zhenya Tulusha on 17.11.10.
//  Copyright 2010 DIMALEX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface ZTStoreObserver : NSObject <SKPaymentTransactionObserver> {
	
	
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;

@end
