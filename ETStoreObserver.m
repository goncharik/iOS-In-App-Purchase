//
//  ETStoreObserver.m
//  iOS In-App Purchase
//
//  Created by Zhenya Tulusha on 17.11.10.
//  Copyright 2013 Tulusha.com. All rights reserved.
//

#import "ETStoreObserver.h"
#import "ETStoreManager.h"


@interface ETStoreManager (InternalMethods)

// these three functions are called from ETStoreObserver
- (void) transactionCanceled: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void) provideContent: (NSString*) productIdentifier 
	 transactionReceipt: (NSString*) recieptData;
@end

@implementation ETStoreObserver

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
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[NSString stringWithFormat:@"%@",[transaction.error localizedDescription]]
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
    }	
    
    [[ETStoreManager sharedManager] transactionCanceled:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{		
    NSString *receiptStr = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    [[ETStoreManager sharedManager] provideContent: transaction.payment.productIdentifier transactionReceipt:receiptStr];
    
	//transaction.transactionReceipt - encode with base64 transaction information
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
    NSString *receiptStr = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    [[ETStoreManager sharedManager] provideContent: transaction.payment.productIdentifier transactionReceipt:receiptStr];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}



@end
