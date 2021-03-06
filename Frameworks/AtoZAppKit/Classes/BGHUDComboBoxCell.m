//
//  NGHUDComboBoxCell.m
//  BGHUDAppKit
//
//  Created by Alan Rogers on 10/11/08.
//


#import "BGHUDComboBoxCell.h"

@implementation BGHUDComboBoxCell

@synthesize themeKey;

#pragma mark Drawing Functions

-(id)initTextCell:(NSString *) aString {
	
	self = [super initTextCell: aString];
	
	if(self) {
		
		self.themeKey = @"gradientTheme";
		[self setTextColor: [[[BGThemeManager keyedManager] themeForKey: self.themeKey] textColor]];
		
		if([self drawsBackground] && [[[BGThemeManager keyedManager] themeForKey: self.themeKey] isOverrideFillColor]) {
			fillsBackground = YES;
			[self setDrawsBackground: NO];
		}
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *) aDecoder {
	
	if((self = [super initWithCoder: aDecoder])) {
		
		if([aDecoder containsValueForKey: @"themeKey"]) {
			
			self.themeKey = [aDecoder decodeObjectForKey: @"themeKey"];
			
		} else {
			
			self.themeKey = @"gradientTheme";
		}
		
		[self setTextColor: [[[BGThemeManager keyedManager] themeForKey: self.themeKey] textColor]];
	}
	
	return self;
}

-(void)encodeWithCoder: (NSCoder *) coder {
	
	[super encodeWithCoder: coder];
	
	[coder encodeObject: self.themeKey forKey: @"themeKey"];
}

-(id)copyWithZone:(NSZone *) zone {
	
	BGHUDComboBoxCell *copy = [super copyWithZone: zone];
	
	copy->themeKey = nil;
	[copy setThemeKey: [self themeKey]];
	
	return copy;
}

-(void)drawWithFrame:(NSRect) cellFrame inView:(NSView *) controlView {
	
	//Adjust Rect
	cellFrame = NSInsetRect(cellFrame, 1.5f, 1.5f);
	
	//Create Path
	NSBezierPath *path = [[NSBezierPath alloc] init];
	
	if([self bezelStyle] == NSTextFieldRoundedBezel) {
		
		[path appendBezierPathWithArcWithCenter: NSMakePoint(cellFrame.origin.x + (cellFrame.size.height /2), cellFrame.origin.y + (cellFrame.size.height /2))
										 radius: cellFrame.size.height /2
									 startAngle: 90
									   endAngle: 270];
		
		[path appendBezierPathWithArcWithCenter: NSMakePoint(cellFrame.origin.x + (cellFrame.size.width - (cellFrame.size.height /2)), cellFrame.origin.y + (cellFrame.size.height /2))
										 radius: cellFrame.size.height /2
									 startAngle: 270
									   endAngle: 90];
		
		[path closePath];
	} else {
		
		[path appendBezierPathWithRoundedRect: cellFrame xRadius: 3.0f yRadius: 3.0f];
	}
	
	//Draw Background
	if(fillsBackground) {
		
		[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] textFillColor] set];
		[path fill];
	}
	
	if([self isBezeled] || [self isBordered]) {
		
		[NSGraphicsContext saveGraphicsState];
		
		if([super showsFirstResponder] && [[[self controlView] window] isKeyWindow] && 
		   ([self focusRingType] == NSFocusRingTypeDefault ||
			[self focusRingType] == NSFocusRingTypeExterior)) {
			   
			   [[[[BGThemeManager keyedManager] themeForKey: self.themeKey] focusRing] set];
		   }
		
		[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] strokeColor] set];
		[path setLineWidth: 1.0f];
		[path stroke];
		
		[NSGraphicsContext restoreGraphicsState];
	}
	
	
	NSRect frame = cellFrame;
	
	//Adjust based on Control size
	switch ([self controlSize]) {
			
		case NSRegularControlSize:
			
			frame.size.width = (frame.size.width -21);
			break;
			
		case NSSmallControlSize:
			
			frame.size.width = (frame.size.width - 18);
			break;
			
		case NSMiniControlSize:
			
			frame.size.width += (frame.size.width - 15);			
			break;
	}
	
	// Draw a 'button' around the arrow
	// TODO: Get this behaviour to work...
	//if ([self isBordered]) 
	
	{
		[self drawButtonInRect: cellFrame];
	}
	
	//Draw the arrow
	[self drawArrowsInRect: cellFrame];
	
	
	// Change the selected text colour
	
	NSTextView* view = (NSTextView*)[[controlView window] fieldEditor:NO forObject:controlView];
	
	NSMutableDictionary *dict = [[view selectedTextAttributes] mutableCopy];
	
	
	if([self showsFirstResponder] && [[[self controlView] window] isKeyWindow])
	{
		[dict setObject:[NSColor darkGrayColor] forKey:NSBackgroundColorAttributeName];
		
		[view setTextColor: [[[BGThemeManager keyedManager] themeForKey: self.themeKey] textColor]];
		
	}
	else
	{
		[view setTextColor:[NSColor blackColor] range:[view selectedRange]];
	}
	
	[view setSelectedTextAttributes:dict];
	
	// draw the text field.
	[super drawInteriorWithFrame: frame inView: controlView];
}

-(void)drawButtonInRect:(NSRect) frame {
	NSBezierPath *path = [[NSBezierPath alloc] init];
	
	
	//Adjust based on Control size
	switch ([self controlSize]) {
			
		case NSRegularControlSize:
			
			frame.origin.x += (frame.size.width -20);
			frame.size.width = 20;
			break;
			
		case NSSmallControlSize:
			
			frame.origin.x += (frame.size.width -17);
			frame.size.width = 17;
			
			break;
			
		case NSMiniControlSize:
			
			frame.origin.x += (frame.size.width - 14);
			frame.size.width = 14;
			
			break;
	}
	
	
	[path appendBezierPathWithRoundedRect: frame xRadius: 3.0f yRadius: 3.0f];
	
	NSRect rect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width/2, frame.size.height);
	[path appendBezierPathWithRect:rect];
	
	[path closePath];
	
	[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] normalGradient] drawInBezierPath: path angle: 90];
	
}

-(void)drawArrowsInRect:(NSRect) frame {
	
	
	
	CGFloat arrowWidth;
	CGFloat arrowHeight;
	
	//Adjust based on Control size
	switch ([self controlSize]) {
		default: // Silence uninitialized variable warnings
		case NSRegularControlSize:
			
			frame.origin.x += (frame.size.width -21);
			frame.size.width = 21;
			
			arrowWidth = 3.5f;
			arrowHeight = 2.5f;
			break;
			
		case NSSmallControlSize:
			
			frame.origin.x += (frame.size.width -18);
			frame.size.width = 18;
			
			arrowWidth = 3.5f;
			arrowHeight = 2.5f;
			
			break;
			
		case NSMiniControlSize:
			
			frame.origin.x += (frame.size.width - 15);
			frame.size.width = 15;
			
			arrowWidth = 2.5f;
			arrowHeight = 1.5f;
			break;
	}
	
	NSBezierPath *arrow = [[NSBezierPath alloc] init];
	
	NSPoint points[3];
	
	points[0] = NSMakePoint(frame.origin.x + ((frame.size.width /2) - arrowWidth), frame.origin.y + ((frame.size.height /2) - arrowHeight));
	points[1] = NSMakePoint(frame.origin.x + ((frame.size.width /2) + arrowWidth), frame.origin.y + ((frame.size.height /2) - arrowHeight));
	points[2] = NSMakePoint(frame.origin.x + (frame.size.width /2), frame.origin.y + ((frame.size.height /2) + arrowHeight));
	
	[arrow appendBezierPathWithPoints: points count: 3];
	
	if([self isEnabled]) {
		[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] strokeColor] set];
	} else {
		[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] disabledStrokeColor] set];
	}
	
	[arrow fill];
	
	
}

#pragma mark Helper Methods



@end
