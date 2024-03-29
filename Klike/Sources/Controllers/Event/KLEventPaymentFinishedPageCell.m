//
//  KLEventPaymentFinishedPageCell.m
//  Klike
//
//  Created by Anton Katekov on 14.05.15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLEventPaymentFinishedPageCell.h"



@implementation UIImage (UIImageFunctions)

- (UIImage *) scaleToFillSize: (CGSize)size
{
    CGSize mySize = self.size;
    float scaleX = mySize.width / size.width;
    float scaleY = mySize.height / size.height;
    if (scaleX < scaleY) {
        mySize = CGSizeMake((int)(mySize.width / scaleX), (int)(mySize.height / scaleX));
    }
    else {
        mySize = CGSizeMake((int)(mySize.width / scaleY), (int)(mySize.height / scaleY));
    }
    return [self scaleToSize:mySize];
}

- (UIImage *) scaleToSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
    
    CGImageRelease(scaledImage);
    
    return image;
}

- (UIImage*)filteredImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciImage = [[CIImage alloc] initWithImage:self];
    
    CIFilter *filter = nil;
    CIImage *result = ciImage;
    
//    filter = [CIFilter filterWithName:@"CIColorClamp"];
//    [filter setValue:result forKey:kCIInputImageKey];
//    [filter setValue:[CIVector vectorWithCGRect:CGRectMake(0.2, 0.2, 0.2, 0.2)] forKey:@"inputMinComponents"];
//    result = filter.outputImage;
    
    filter = [CIFilter filterWithName:@"CIDotScreen"];
    [filter setValue:result forKey:kCIInputImageKey];
    [filter setValue:@0.7 forKey:kCIInputSharpnessKey];
    [filter setValue:@4.0 forKey:@"inputWidth"];
    result = filter.outputImage;
    
    filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:result forKey:kCIInputImageKey];
    result = filter.outputImage;
    
    filter = [CIFilter filterWithName:@"CIMaskToAlpha"];
    [filter setValue:result forKey:kCIInputImageKey];
    result = filter.outputImage;
    
    filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:result forKey:kCIInputImageKey];
    result = filter.outputImage;
    
    filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:result forKey:kCIInputImageKey];
    [filter setValue:@1.0 forKey:@"inputIntensity"];
    CGColorRef colorRef = [UIColor blackColor].CGColor;
    NSString *colorString = [CIColor colorWithCGColor:colorRef].stringRepresentation;
    CIColor *coreColor = [CIColor colorWithString:colorString];
    [filter setValue:coreColor forKey:@"inputColor"];
    result = [filter valueForKey:kCIOutputImageKey];
    
    
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    UIImage *filteredImage = [[UIImage alloc] initWithCGImage:cgImage];
    
    return filteredImage;
}

@end



@implementation KLEventPaymentFinishedPageCell

- (void)awakeFromNib
{
    _color = [UIColor colorFromHex:0x0494b3];
    
    CGSize sz = _imageEvent.frame.size;
    {
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(0, 0, sz.width, sz.height);
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"p_halftone_pic_mask"] CGImage];
        _imageEvent.layer.mask = maskLayer;
    }
    {
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(0, 0, sz.width, sz.height);
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"p_halftone_pic_mask"] CGImage];
        _imageEventDirt.layer.mask = maskLayer;
    }
    
    
    [self setThrowInInfo];
}

- (void)setType:(KLEventPaymentFinishedPageCellType)type
{
    if (type == KLEventPaymentFinishedPageCellTypeBuy)
    {
        _color = [UIColor colorFromHex:0x5d93e3];
        _viewBackground.backgroundColor = _color;
        _imageEvent.backgroundColor = _color;
        _imageCorner.image = [UIImage imageNamed:@"p_ticket_m"];
        _imageCornerL.image = [UIImage imageNamed:@"p_ticket_l"];
    }
    else
    {
        _color = [UIColor colorFromHex:0x1ba9c7];
        _viewBackground.backgroundColor = _color;
        _imageEvent.backgroundColor = _color;
        _imageCorner.image = [UIImage imageNamed:@"p_ticket_throw_in_m"];
        _imageCornerL.image = [UIImage imageNamed:@"p_ticket_throw_in_l"];
        
    }
    _labelThrowedIn.hidden = type == KLEventPaymentFinishedPageCellTypeBuy;
    _labelTickets.hidden = type != KLEventPaymentFinishedPageCellTypeBuy;
    _labelTicketsBottom.hidden = type != KLEventPaymentFinishedPageCellTypeBuy;
//    [self setEventImage:[UIImage imageNamed:@"TestPhotoUser_0"]];
}

- (void)setEventImage:(UIImage*)image
{
    _imageEvent.image = [[image scaleToFillSize:_imageEvent.frame.size] filteredImage];
}

- (void)setThrowInInfo
{
    [self setType:(KLEventPaymentFinishedPageCellTypeThrow)];
}

- (void)setBuyTicketsInfo
{
    [self setType:(KLEventPaymentFinishedPageCellTypeBuy)];
}

- (void)setTickets:(int)value
{
    if (value == 0) {
        _labelThrowedIn.hidden = NO;
        _labelTickets.hidden = YES;
        _labelTicketsBottom.hidden = YES;
        _labelThrowedIn.text = @"0 Tickets";
    }
    else {
        _labelTickets.text = [NSString stringWithFormat:@"%d Tickets", value];
    }
}

- (void)setThrowedIn:(int)value
{
    _labelThrowedIn.text = [NSString stringWithFormat:@"$%d Thrown in", value];
}

- (IBAction)onFullscreen:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(paymentFinishedCellDidPressTicket)]) {
        [self.delegate performSelector:@selector(paymentFinishedCellDidPressTicket) withObject:nil];
    }
    
}

- (void)configureWithEvent:(KLEvent *)event
{
    [super configureWithEvent:event];
    
    KLEventPrice *price = self.event.price;
    KLEventPricingType priceType = price.pricingType.intValue;
    
    if (priceType == KLEventPricingTypePayed) {
        [self setBuyTicketsInfo];
        [self setTickets:[[KLEventManager sharedManager] boughtTicketsForEvent:self.event].intValue];
    }
    else if (priceType == KLEventPricingTypeThrow) {
        [self setThrowInInfo];
        [self setThrowedIn:[[KLEventManager sharedManager] thrownInForEvent:self.event].floatValue];
    }
}

@end
