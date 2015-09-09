//
//  ValueConverterAppDelegate.h
//  ValueConverterAppDelegate
//
//  Created by Uli Kusterer on 24.11.04.
//  Copyright M. Uli Kusterer 2004. All rights reserved.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "UKColumnRowFilledBgView.h" 


// -----------------------------------------------------------------------------
//  App delegate class:
// -----------------------------------------------------------------------------

@interface ValueConverterAppDelegate : NSObject
{
    IBOutlet NSTextField			*binaryLongLongField;
    IBOutlet NSTextField			*eightCharCodeField;
    IBOutlet NSTextField			*hexLongLongField;
    IBOutlet NSMatrix					*bitfieldMatrix;
	IBOutlet UKColumnRowFilledBgView	*bitfieldBg;
    IBOutlet NSTextField			*octalLongLongField;
    IBOutlet NSTextField			*signedLongLongField;
    IBOutlet NSTextField			*unsignedLongLongField;
    IBOutlet NSTextField			*signedLongField;
    IBOutlet NSTextField			*unsignedLongField;
    IBOutlet NSTextField			*signedShortField;
    IBOutlet NSTextField			*unsignedShortField;
    IBOutlet NSTextField			*signedByteField;
    IBOutlet NSTextField			*unsignedByteField;
    IBOutlet NSTextField			*floatField;
    
    IBOutlet NSButton				*uppercaseEscapesSwitch;
    IBOutlet NSButton				*uppercaseHexSwitch;
    IBOutlet NSButton				*clearLongLongHighLongSwitch;
    IBOutlet NSButton				*clearShortHighWordSwitch;
    IBOutlet NSButton				*clearByteHighBytesSwitch;
	IBOutlet NSSegmentedControl		*endianSwitch;
    IBOutlet NSTextField			*bitshiftAmountField;
	IBOutlet NSPopUpButton			*encodingPopup;
    
    unsigned long long				value;					// The actual 8-byte value that is displayed in the window.
    BOOL							uppercaseEscapes;		// Use uppercase A's etc. in hex escape sequences?
    BOOL							uppercaseHex;			// Use uppercase A's etc. in hex display?
    BOOL							clearLongLongHighLong;	// Set the high long to 0 when editing a long long?
    BOOL							clearShortHighWord;		// Set the high word to 0 when editing a short?
    BOOL							clearByteHighBytes;		// Set the 3 high bytes to 0 when editing a byte?
	BOOL							doEndianConversion;		// Do endian-conversion instead of using native endianness?
	int								bitshiftAmount;			// How much to bitshift on one button press.
	NSStringEncoding				charsEncoding;			// Text encoding to use for display as chars.
}

// Various UI actions that change value:
-(IBAction) bitMatrixChanged: (id)sender;
-(IBAction) takeBinaryLongLongStringFrom: (id)sender;
-(IBAction) takeEightCharCodeStringFrom: (id)sender;
-(IBAction) takeHexLongLongStringFrom: (id)sender;
-(IBAction) takeOctalLongLongStringFrom: (id)sender;
-(IBAction) takeSignedLongLongStringFrom: (id)sender;
-(IBAction) takeUnsignedLongLongStringFrom: (id)sender;
-(IBAction) takeSignedLongStringFrom: (id)sender;
-(IBAction) takeUnsignedLongStringFrom: (id)sender;
-(IBAction) takeSignedShortStringFrom: (id)sender;
-(IBAction) takeUnsignedShortStringFrom: (id)sender;
-(IBAction) takeSignedByteStringFrom: (id)sender;
-(IBAction) takeUnsignedByteStringFrom: (id)sender;
-(IBAction) takeFloatStringFrom: (id)sender;
-(IBAction)	shiftInDirection: (id)sender;	// Tag must be 1 or -1 to indicate direction.

// Make UI update its display of value:
-(void)     refreshDisplay: (id)sender;

// UI Actions for changing prefs:
-(IBAction) toggleUppercaseEscapes: (id)sender;
-(IBAction) toggleUppercaseHex: (id)sender;
-(IBAction) toggleClearLongLongHighLong: (id)sender;
-(IBAction) toggleClearShortHighWord: (id)sender;
-(IBAction) toggleClearByteHighBytes: (id)sender;
-(IBAction)	toggleEndianness: (id)sender;
-(IBAction)	takeBitshiftAmountFrom: (id)sender;
-(IBAction)	takeEncodingIndexFrom: (id)sender;

@end
