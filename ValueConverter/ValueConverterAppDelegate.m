//
//  ValueConverterAppDelegate.m
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

#import "ValueConverterAppDelegate.h"
#import "NSString+EscapeString.h"

#if BYTE_ORDER == BIG_ENDIAN
#define CONVERT_SEGMENT			1
#define DONT_CONVERT_SEGMENT	0
#else
#define CONVERT_SEGMENT			0
#define DONT_CONVERT_SEGMENT	1
#endif


@implementation ValueConverterAppDelegate

NSString*		encodingNames[] = { @"MacRoman", @"UTF-8", @"ISO Latin 1", nil };
NSInteger		encodingConstants[] = { NSMacOSRomanStringEncoding, NSUTF8StringEncoding, NSISOLatin1StringEncoding, 0 };

// -----------------------------------------------------------------------------
//  awakeFromNib:
//      Make sure all text fields are synched to our value immediately after
//      our window's been loaded, and fetch last-used value from prefs.
//
//  REVISIONS:
//      2004-11-27  UK  Added loading of prefs.
//      2004-11-26  UK  documented.
// -----------------------------------------------------------------------------

-(void) awakeFromNib
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSNumber*       num = nil;
    
    // Defaults:
    value = 0;
    uppercaseEscapes = NO;
    uppercaseHex = YES;
    clearShortHighWord = NO;
    clearByteHighBytes = NO;
    clearLongLongHighLong = NO;
    
    // Now get prefs, if set:
    num = [ud objectForKey: @"UppercaseEscapes"];
    if( num )
        uppercaseEscapes = [num boolValue];

    num = [ud objectForKey: @"UppercaseHex"];
    if( num )
        uppercaseHex = [num boolValue];

    num = [ud objectForKey: @"ClearLongLongHighLong"];
    if( num )
        clearLongLongHighLong = [num boolValue];
    
    num = [ud objectForKey: @"ClearShortHighWord"];
    if( num )
        clearShortHighWord = [num boolValue];
    
    num = [ud objectForKey: @"ClearByteHighBytes"];
    if( num )
        clearByteHighBytes = [num boolValue];
    
    num = [ud objectForKey: @"BitshiftAmount"];
    if( num )
        bitshiftAmount = [num intValue];
	if( bitshiftAmount < 1 || bitshiftAmount >= 64 )
		bitshiftAmount = 1;
    
    NSData* theData = [ud objectForKey: @"LastUsedValueBytes"];
    if( theData )
        [theData getBytes: &value length: 8];
	
	charsEncoding = NSMacOSRomanStringEncoding;
    num = [ud objectForKey: @"CharsEncoding"];
    if( num )
        charsEncoding = [num intValue];
    
    // Update UI:
    [uppercaseEscapesSwitch setState: uppercaseEscapes];
    [uppercaseHexSwitch setState: uppercaseHex];
    [clearLongLongHighLongSwitch setState: clearLongLongHighLong];
    [clearShortHighWordSwitch setState: clearShortHighWord];
    [clearByteHighBytesSwitch setState: clearByteHighBytes];
    [bitshiftAmountField setIntValue: bitshiftAmount];
	
	// Build & select encoding popup:
	int					indexToSelect = 0;
	for( int x = 0; encodingNames[x] != nil; x++ )
	{
		[encodingPopup addItemWithTitle: encodingNames[x]];
		if( charsEncoding == encodingConstants[x] )
			indexToSelect = x;
	}
	[encodingPopup selectItemAtIndex: indexToSelect];
	
	// Endian switch starts out with native endianness:
	[endianSwitch setSelectedSegment: DONT_CONVERT_SEGMENT];
	
	// Set up rows and columns behind our matrix:
	[bitfieldBg setRowHeight: 20 atIndex: 0];
	[bitfieldBg setRowHeight: 20 atIndex: 1];
	[bitfieldBg setRowHeight: 20 atIndex: 2];
	[bitfieldBg setRowHeight: 20 atIndex: 3];
	[bitfieldBg setRowHeight: 26 atIndex: 4];
	[bitfieldBg setColumnWidth: 80 atIndex: 0];
	[bitfieldBg setColumnWidth: 184 atIndex: 1];
	[bitfieldBg setColumnWidth: 190 atIndex: 2];
	
    [self refreshDisplay: nil];
}


// -----------------------------------------------------------------------------
//  applicationWillTerminate:
//      Remember last value we displayed so we can load it again at next launch.
//
//  REVISIONS:
//      2004-11-27  UK  Added saving of prefs.
//      2004-11-26  UK  documented.
// -----------------------------------------------------------------------------

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSUserDefaults*     ud = [NSUserDefaults standardUserDefaults];
    NSData*				num = [NSData dataWithBytes: &value length: 8];
    [ud setObject: num forKey: @"LastUsedValueBytes"];
    [ud setBool: uppercaseEscapes forKey: @"UppercaseEscapes"];
    [ud setBool: uppercaseHex forKey: @"UppercaseHex"];
    [ud setBool: clearShortHighWord forKey: @"ClearLongLongHighLong"];
    [ud setBool: clearShortHighWord forKey: @"ClearShortHighWord"];
    [ud setBool: clearByteHighBytes forKey: @"ClearByteHighBytes"];
	
	[ud setInteger: bitshiftAmount forKey: @"BitshiftAmount"];
	[ud setInteger: charsEncoding forKey: @"CharsEncoding"];
}


// -----------------------------------------------------------------------------
//  applicationShouldTerminateAfterLastWindowClosed:
//      Make sure closing the window quits the app.
//
//  REVISIONS:
//      2004-11-26  UK  documented.
// -----------------------------------------------------------------------------

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


// -----------------------------------------------------------------------------
//  Methods that apply user's changes to our value:
// -----------------------------------------------------------------------------

// Click in one of our 64 bit-checkboxes:
- (IBAction)bitMatrixChanged:(id)sender
{
    NSEnumerator*		cellEnny = [[sender cells] reverseObjectEnumerator];    // Bit 0 is at lower right, bit 31 at upper left. So we need to reverse-iterate.
    unsigned long long  bx = 0;
    NSCell*				currCell;
    
    value = 0;
    
    while( (currCell = [cellEnny nextObject]) )
    {
		#if BYTE_ORDER == LITTLE_ENDIAN
		unsigned long long	idx = (bx / 8LL) * 8LL;
		idx += bx % 8LL;
		#else
		unsigned long long	idx = bx;
		#endif
		
        if( [currCell state] )
            value |= (1LL << idx);
        
        bx++;
    }
	
	if( BYTE_ORDER == LITTLE_ENDIAN )
		value = NSSwapLongLong(value);
	
    [self refreshDisplay: sender];
}


// binary long long field changed:
- (IBAction)takeBinaryLongLongStringFrom:(id)sender
{
    NSString*   str = [sender stringValue];
    int         x, bx = 0;
    
    value = 0;
    
    for( x = [str length] -1; x >= 0; x-- )
    {
        if( [str characterAtIndex: x] == '1' )
            value |= (1LL << (unsigned long long)bx);
        
        bx++;
    }
	
	if( doEndianConversion )
		value = NSSwapLongLong(value);
    
    [self refreshDisplay: sender];
}


// The four bytes re-interpreted as four ASCII characters:
- (IBAction)takeEightCharCodeStringFrom:(id)sender
{
    char    str[9] = { 0 };
    
	NS_DURING
		[[[sender stringValue] unescapedString] getCString: str maxLength: sizeof(str) encoding: charsEncoding];
	NS_HANDLER
	NS_ENDHANDLER
    memmove( &value, str, 8 );
    
    [self refreshDisplay: sender];
}


// Hexadecimal long:
- (IBAction)takeHexLongLongStringFrom:(id)sender
{
    NSString*	str = [sender stringValue];
    int			x, hx = 0;
    
    value = 0;
    
    for( x = [str length] -1; x >= 0; x-- )
    {
        unsigned long long currVal = UKHexToDec([str characterAtIndex: x]);
        value += currVal * (unsigned long long) pow(16,hx);  // Base 16!
        
        hx++;
    }
 
	if( doEndianConversion )
		value = NSSwapLongLong(value);
    
    [self refreshDisplay: sender];
}


// Octal long long:
- (IBAction)takeOctalLongLongStringFrom:(id)sender
{
    NSString*			str = [sender stringValue];
    int					x, ox = 0;
    
    value = 0;
    
    for( x = [str length] -1; x >= 0; x-- )
    {
        unsigned long long currVal = [str characterAtIndex: x] - '0';
        value += currVal * (unsigned long long)pow(8,ox);   // Base 8!
        
        ox++;
    }
    
	if( doEndianConversion )
		value = NSSwapLongLong(value);
    
    [self refreshDisplay: sender];
}


// Signed long (4 bytes):
- (IBAction)takeSignedLongStringFrom:(id)sender
{
    int		n = [sender intValue];
    if( clearLongLongHighLong )
		((long*)&value)[1] = 0;
	
	if( doEndianConversion )
		n = NSSwapLong(n);
    
	((long*)&value)[0] = n;
	
    [self refreshDisplay: sender];
}


// Signed long long (8 bytes):
- (IBAction)takeSignedLongLongStringFrom:(id)sender
{
    value = [[sender stringValue] longLongValue];
	if( doEndianConversion )
		value = NSSwapLongLong(value);
    
    [self refreshDisplay: sender];
}


// Signed short (2 bytes):
- (IBAction)takeSignedShortStringFrom:(id)sender
{
    short n = [sender intValue];
    if( clearShortHighWord )
    {
	    ((short*)&value)[1] = 0;
	    ((short*)&value)[2] = 0;
	    ((short*)&value)[3] = 0;
	}
    
	if( doEndianConversion )
		n = NSSwapShort(n);
    ((short*)&value)[0] = n;
    
    [self refreshDisplay: sender];
}


// Unsigned short (2 bytes):
- (IBAction)takeUnsignedShortStringFrom:(id)sender
{
    short n = [sender intValue];
    if( clearShortHighWord )
    {
	    ((short*)&value)[1] = 0;
	    ((short*)&value)[2] = 0;
	    ((short*)&value)[3] = 0;
	}
    
	if( doEndianConversion )
		n = NSSwapLong(n);
    ((short*)&value)[0] = n;
    
    [self refreshDisplay: sender];
}


// Unsigned byte (1 byte):
- (IBAction)takeSignedByteStringFrom:(id)sender
{
    char n = [sender intValue];
    if( clearByteHighBytes )
    {
        ((char*)&value)[1] = 0;
        ((char*)&value)[2] = 0;
		((char*)&value)[3] = 0;
        ((char*)&value)[4] = 0;
        ((char*)&value)[5] = 0;
        ((char*)&value)[6] = 0;
        ((char*)&value)[7] = 0;
	}

    ((char*)&value)[0] = n;
    
    [self refreshDisplay: sender];
}


- (IBAction)takeUnsignedByteStringFrom:(id)sender
{
    char n = [sender intValue];
    if( clearByteHighBytes )
    {
        ((char*)&value)[1] = 0;
        ((char*)&value)[2] = 0;
		((char*)&value)[3] = 0;
        ((char*)&value)[4] = 0;
        ((char*)&value)[5] = 0;
        ((char*)&value)[6] = 0;
        ((char*)&value)[7] = 0;
   }
    ((char*)&value)[0] = n;
    
    [self refreshDisplay: sender];
}


// unsigned long (on PPC, has same value as unsigned short and unsigned byte if you clear the excess bits):
- (IBAction)takeUnsignedLongStringFrom:(id)sender
{
    NSString*		str = [sender stringValue];
    int				x, dx = 0;
	unsigned long	n = 0;
    
	if( clearLongLongHighLong )
		((unsigned long*)&value)[1] = 0;
    
    for( x = [str length] -1; x >= 0; x-- )
    {
        int currVal = [str characterAtIndex: x] - '0';
        n += currVal * pow(10,dx);
        
        dx++;
    }
    
	if( doEndianConversion )
		n = NSSwapLong(n);
    ((unsigned long*)&value)[0] = n;
    
    [self refreshDisplay: sender];
}


// unsigned long long (on PPC, has same value as unsigned short, unsigned long and unsigned byte if you clear the excess bits):
- (IBAction)takeUnsignedLongLongStringFrom:(id)sender
{
    NSString*   str = [sender stringValue];
    int         x, dx = 0;
    
    value = 0;
    
    for( x = [str length] -1; x >= 0; x-- )
    {
        int currVal = [str characterAtIndex: x] - '0';
        value += currVal * pow(10,dx);
        
        dx++;
    }
    
	if( doEndianConversion )
		value = NSSwapLongLong(value);
    
    [self refreshDisplay: sender];
}


// -----------------------------------------------------------------------------
//  takeFloatStringFrom:
//      Generate an (unsigned) float based on the sender's string value.
//
//  REVISIONS:
//      2005-01-09  UK  Fixed comment.
//      2004-11-27  UK  Created.
// -----------------------------------------------------------------------------

-(IBAction) takeFloatStringFrom: (id)sender
{
    const char*   cstr = [[sender stringValue] cStringUsingEncoding: NSASCIIStringEncoding];
    char*         edptr = (char*) cstr +strlen(cstr);
    
	if( clearLongLongHighLong )
		((float*)&value)[1] = 0;
    float n = strtof( cstr, &edptr );
    
 	if( doEndianConversion )
		(*(NSSwappedFloat*)&n) = NSSwapFloat( *(NSSwappedFloat*)&n);
	((float*)&value)[0] = n;
    
   [self refreshDisplay: sender];
}


// -----------------------------------------------------------------------------
//  controlTextDidChange:
//      Trigger the action 'live', on every keypress.
// -----------------------------------------------------------------------------

-(void)	controlTextDidChange: (NSNotification *)notif
{
	id	sender = [notif object];
	SEL	action = [sender action];
	id	target = [sender target];
	
	[target performSelector: action withObject: sender];
}


// -----------------------------------------------------------------------------
//  octalString:
//      Generate an (unsigned) octal string based on the number n. This should
//      probably be a category on NSString or NSNumber instead...
//
//  REVISIONS:
//      2004-11-26  UK  documented.
// -----------------------------------------------------------------------------

-(NSString*)   octalString: (unsigned long long)n
{
    NSMutableString*    str = [NSMutableString string];
    int                 x;
    
    for( x = 0; x < 22; x++ )
    {
        unsigned long long	shift = (x *3);
        unsigned long long	shifted = (n >> shift);
        int         currDig = (shifted & 0x7);
		if( x == 21 )
			currDig = (shifted & 0x1);
        char        vals[8] = { '0', '1', '2', '3', '4', '5', '6', '7' };
        [str insertString: [[[NSString alloc] initWithBytes: (vals +currDig) length: 1 encoding: NSASCIIStringEncoding] autorelease] atIndex: 0];
    }
    
	// Remove leading zeroes:
	NSRange		finalRange = NSMakeRange( 0, [str length] );
	NSInteger	c = 0, count = [str length];
	
	for( c = 0; c < count; c++ )
	{
		unichar currCh = [str characterAtIndex: c];
		if( currCh == '0' )
		{
			finalRange.location ++;
			finalRange.length--;
		}
		else
			break;
	}
	
	if( finalRange.length == 0 )
		return @"0";
	else
		return [str substringWithRange: finalRange];
}


// -----------------------------------------------------------------------------
//  binaryString:
//      Generate an (unsigned) binary string based on the number n. This should
//      probably be a category on NSString or NSNumber instead...
//
//  REVISIONS:
//      2004-11-26  UK  documented.
// -----------------------------------------------------------------------------

-(NSString*)   binaryString: (unsigned long long)n
{
    NSMutableString*    str = [NSMutableString string];
    int                 x;
    
    for( x = 0; x < 64; x++ )
    {
        unsigned    shifted = (n >> x);
        int         currDig = (shifted & 0x1);
        char        vals[2] = { '0', '1' };
        [str insertString: [[[NSString alloc] initWithBytes: (vals +currDig) length: 1 encoding: NSASCIIStringEncoding] autorelease] atIndex: 0];
    }
    
	// Remove leading zeroes:
	NSRange		finalRange = NSMakeRange( 0, [str length] );
	NSInteger	c = 0, count = [str length];
	
	for( c = 0; c < count; c++ )
	{
		unichar currCh = [str characterAtIndex: c];
		if( currCh == '0' )
		{
			finalRange.location ++;
			finalRange.length--;
		}
		else
			break;
	}
	
	if( finalRange.length == 0 )
		return @"0";
	else
		return [str substringWithRange: finalRange];
}

// -----------------------------------------------------------------------------
//  refreshDisplay:
//      Update our display to reflect the "value" instance variable.
//
//  REVISIONS:
//      2004-11-26  UK  documented.
// -----------------------------------------------------------------------------

-(void)     refreshDisplay: (id)sender
{
	unsigned long long	possiblySwappedLL = doEndianConversion? NSSwapLongLong(value) : value;
	unsigned long		possiblySwappedL = doEndianConversion? NSSwapLong((*(unsigned long*)&value)) : (*(unsigned long*)&value);
	unsigned short		possiblySwappedS = doEndianConversion? NSSwapShort((*(unsigned short*)&value)) : (*(unsigned short*)&value);
	unsigned char		theCh = (*(unsigned char*)&value);
	NSSwappedFloat		swappedF = NSSwapFloat((*(NSSwappedFloat*)&value));
	float				possiblySwappedF = doEndianConversion? (*(float*)&swappedF) : (*(float*)&value);
	if( sender != binaryLongLongField )
		[binaryLongLongField setStringValue: [self binaryString: possiblySwappedLL]];
    if( sender != hexLongLongField )
		[hexLongLongField setStringValue: [NSString stringWithFormat: uppercaseHex ? @"%llX" : @"%llx", possiblySwappedLL]];
    if( sender != signedLongLongField )
		[signedLongLongField setStringValue: [NSString stringWithFormat: @"%lld",possiblySwappedLL]];
    if( sender != unsignedLongLongField )
		[unsignedLongLongField setStringValue: [NSString stringWithFormat: @"%llu",possiblySwappedLL]];
    if( sender != signedLongField )
		[signedLongField setStringValue: [NSString stringWithFormat: @"%ld", possiblySwappedL]];
	if( sender != unsignedLongField )
		[unsignedLongField setStringValue: [NSString stringWithFormat: @"%lu", possiblySwappedL]];
    if( sender != octalLongLongField )
		[octalLongLongField setStringValue: [self octalString: possiblySwappedLL]];
    if( sender != floatField )
		[floatField setStringValue: [NSString stringWithFormat: @"%f", possiblySwappedF]];
    
    if( sender != signedShortField )
		[signedShortField setStringValue: [NSString stringWithFormat: @"%d", possiblySwappedS]];
	if( sender != unsignedShortField )
		[unsignedShortField setStringValue: [NSString stringWithFormat: @"%u", possiblySwappedS]];
	
    if( sender != signedByteField )
		[signedByteField setStringValue: [NSString stringWithFormat: @"%d", (signed char) theCh]];
    if( sender != unsignedByteField )
		[unsignedByteField setStringValue: [NSString stringWithFormat: @"%u", theCh]];
    
	if( sender != eightCharCodeField )
	{
		char str[9] = { 0 };
		memmove( str, &value, 8 );
		NSString*   ecc = @"";
		NS_DURING
			ecc = [[[NSString alloc] initWithBytes: str length: 8 encoding: charsEncoding] autorelease];
		NS_HANDLER
		NS_ENDHANDLER
		if( !ecc )
			ecc = @"";
		[eightCharCodeField setStringValue: [ecc escapedStringUppercase: uppercaseEscapes]];
    }
	
    // Now our matrix of checkboxes:
	if( sender != bitfieldMatrix )
	{
		unsigned long long	num = (unsigned long long)value;
		if( BYTE_ORDER == LITTLE_ENDIAN )
			num = NSSwapLongLong(num);
		
		int                 x;
		
		for( x = 0; x < 64; x++ )
		{
			unsigned			shifted = (num >> x);
			int					row = (x / 16);
			int					col = (x % 16);
			int					yRow = 3-row;
			int					xCol = 15-col;
			NSInteger			currBitValue = (shifted & 0x1);
			
			[bitfieldMatrix setState: currBitValue atRow: yRow column: xCol];    // 3- because we want low-order at bottom, 15- so we get low-order bits at right.
		}
	}
}


-(IBAction) toggleUppercaseEscapes: (id)sender
{
    uppercaseEscapes = !uppercaseEscapes;
}


-(IBAction) toggleUppercaseHex: (id)sender
{
    uppercaseHex = !uppercaseHex;
}


-(IBAction) toggleClearLongLongHighLong: (id)sender
{
    clearLongLongHighLong = !clearLongLongHighLong;
}


-(IBAction) toggleClearShortHighWord: (id)sender
{
    clearShortHighWord = !clearShortHighWord;
}


-(IBAction) toggleClearByteHighBytes: (id)sender
{
    clearByteHighBytes = !clearByteHighBytes;
}


-(IBAction) toggleEndianness: (id)sender
{
    doEndianConversion = !doEndianConversion;
	
	[endianSwitch setSelectedSegment: doEndianConversion ? CONVERT_SEGMENT : DONT_CONVERT_SEGMENT];
	
	[self refreshDisplay: self];
}

-(IBAction)	shiftInDirection: (id)sender
{
	int	dir = [sender tag];
	unsigned long long		theValue = (BYTE_ORDER == LITTLE_ENDIAN) ? NSSwapLongLong(value) : value;
	if( dir > 0 )
	{
		for( int x = 0; x < bitshiftAmount; x++ )
		{
			unsigned long long	oldLowBit = (theValue & 1LL) << 63LL;
			theValue >>= 1LL;
			theValue |= oldLowBit;
		}
	}
	else
	{
		for( int x = 0; x < bitshiftAmount; x++ )
		{
			unsigned long long	oldHiBit = (theValue & 0x8000000000000000LL) >> 63LL;
			theValue <<= 1LL;
			theValue |= oldHiBit;
		}
	}
	value = (BYTE_ORDER == LITTLE_ENDIAN) ? NSSwapLongLong(theValue) : theValue;
	
	[self refreshDisplay: self];
}


-(IBAction)	takeBitshiftAmountFrom: (id)sender
{
	bitshiftAmount = [sender intValue];
	if( bitshiftAmount < 1 )
		bitshiftAmount = 1;
	if( bitshiftAmount >= 64 )
		bitshiftAmount = 1;
	
	[bitshiftAmountField setIntValue: bitshiftAmount];
}


-(IBAction)	takeEncodingIndexFrom: (id)sender
{
	int		idx = [sender indexOfSelectedItem];
	charsEncoding = encodingConstants[idx];
	
	[self takeEightCharCodeStringFrom: eightCharCodeField];
}

@end
