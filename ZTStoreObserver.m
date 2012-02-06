//
//  ZTStoreObserver.m
//  iOS In-App Purchase
//
//  Created by Zhenya Tulusha on 17.11.10.
//  Copyright 2010 DIMALEX. All rights reserved.
//

#import "ZTStoreObserver.h"
#import "ZTStoreManager.h"


@interface ZTStoreManager (InternalMethods)

// these three functions are called from ZTStoreObserver
- (void) transactionCanceled: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void) provideContent: (NSString*) productIdentifier 
	 transactionReceipt: (NSString*) recieptData;
@end

@implementation ZTStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				
                [self completeTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateRestored:
				
                [self restoreTransaction:transaction];
				
            default:
				
                break;
		}			
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{	
	if (transaction.error.code != SKErrorPaymentCancelled)		
    {		

        // Optionally, display an error here.	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",[transaction.error localizedDescription]]
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];	
    }	
    
    [[ZTStoreManager sharedManager] transactionCanceled:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{		
    NSString *receiptStr = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    [[ZTStoreManager sharedManager] provideContent: transaction.payment.productIdentifier transactionReceipt:receiptStr];	
    
	//transaction.transactionReceipt - encode with base64 transaction information
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
    NSString *receiptStr = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    [[ZTStoreManager sharedManager] provideContent: transaction.payment.productIdentifier transactionReceipt:receiptStr];	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}



@end
