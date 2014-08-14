//
//  CSCircularAvatar
//
// Copyright (c) 2014 Shunkuei Chang
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CSCircularAvatar.h"
#import <QuartzCore/QuartzCore.h>
#import "POP/POP.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle - 90) / 180.0 * M_PI)

#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define DEFAULT_BASERING_OPACITY            0.5f
#define DEFAULT_RING_STROKEWIDTH            2
#define DEFAULT_BASERING_STROKECOLOR        [UIColor lightGrayColor]
#define DEFAULT_PROGRESSRING_STROKECOLOR    [UIColor whiteColor]
#define DEFAULT_BACKGROUND_COLOR            [UIColor clearColor]


//////////

@interface CSCircularAvatar ()
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) UIBezierPath *circlePath;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *currentProgressLayer;
@property (nonatomic, strong) CAShapeLayer *outerRingBaseLayer;
@property (nonatomic, strong) CAShapeLayer *avatarLayer;
@property (nonatomic, assign) float previousValue;

@end


@implementation CSCircularAvatar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initAttributes];
    }
    return self;
}


- (void)initAttributes
{
    _previousValue = 0;
    
    _backgroundLayerColor = DEFAULT_BACKGROUND_COLOR;
    _baseRingStrokeWidth = DEFAULT_RING_STROKEWIDTH;
    _baseStrokeColor = DEFAULT_BASERING_STROKECOLOR;
    _baseRingOpacity = DEFAULT_BASERING_OPACITY;

    _progressRingStrokeWidth = DEFAULT_RING_STROKEWIDTH;
    _progressStrokeColor = DEFAULT_PROGRESSRING_STROKECOLOR;
    
    CGPoint arcCenter = CGPointMake(CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds));
    CGFloat radius = MIN(CGRectGetMidX(self.bounds) - (self.baseRingStrokeWidth/2),CGRectGetMidY(self.bounds) - (self.baseRingStrokeWidth/2));
    
    self.circlePath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                     radius:radius
                                                 startAngle:DEGREES_TO_RADIANS(0)
                                                   endAngle:DEGREES_TO_RADIANS(360)
                                                  clockwise:YES];

    [self.layer addSublayer:self.backgroundLayer];      //layer 0
    [self.layer addSublayer:self.avatarLayer];          //layer 1
    [self.layer addSublayer:self.outerRingBaseLayer];   //layer 2
    [self.layer addSublayer:self.currentProgressLayer]; //layer 3
    
    
}







- (CAShapeLayer *)currentProgressLayer {
    
    if (_currentProgressLayer == nil) {
        
        _currentProgressLayer = [CAShapeLayer layer];
        _currentProgressLayer.zPosition = 3;
        _currentProgressLayer.lineWidth = DEFAULT_RING_STROKEWIDTH;
        _currentProgressLayer.fillColor = [UIColor clearColor].CGColor;
        _currentProgressLayer.strokeColor = self.progressStrokeColor.CGColor;
        _currentProgressLayer.strokeStart = 0.0f;
        _currentProgressLayer.strokeEnd = self.previousValue;
        _currentProgressLayer.path = [self circlePath].CGPath;
        
    }
    
    return _currentProgressLayer;
}

- (CAShapeLayer *)avatarLayer
{
    if (_avatarLayer == nil) {
        
        self.avatarLayer = [CALayer layer];
        
        self.avatarLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        
        UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = aPath.CGPath;
        
        self.avatarLayer.cornerRadius = self.bounds.size.height/2.0f;
        
        self.avatarLayer.masksToBounds = YES;
        self.avatarLayer.zPosition = 1;
        self.avatarLayer.hidden = YES;

    }
    return _avatarLayer;
}


- (CAShapeLayer *)backgroundLayer
{
    if (_backgroundLayer == nil)
    {
        self.backgroundLayer = [CAShapeLayer layer];
        self.backgroundLayer.path = self.circlePath.CGPath;
        self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
        self.backgroundLayer.anchorPoint = CGPointMake(0.5, 0.5);
        self.backgroundLayer.zPosition = 0;
    }
    return _backgroundLayer;
}

- (CAShapeLayer *)outerRingBaseLayer
{
    if (_outerRingBaseLayer == nil)
    {
        self.outerRingBaseLayer = [CAShapeLayer layer];
        self.outerRingBaseLayer.path = self.circlePath.CGPath;
        self.outerRingBaseLayer.strokeColor = self.baseStrokeColor.CGColor;
        self.outerRingBaseLayer.opacity = self.baseRingOpacity;
        self.outerRingBaseLayer.fillColor = [[UIColor clearColor] CGColor];
        self.outerRingBaseLayer.lineWidth = self.baseRingStrokeWidth;
        self.outerRingBaseLayer.anchorPoint = CGPointMake(0.5, 0.5);
        self.outerRingBaseLayer.zPosition = 2;
    }
    return _outerRingBaseLayer;
}


- (void)setAvatar:(UIImage *)avatar animation:(BOOL)animation
{

    if(self.avatarLayer.hidden)
    {
        self.avatarLayer.hidden = NO;
    }
    
    self.avatarLayer.contents =  (__bridge id)(avatar.CGImage);

    if(animation)
    {
        
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(0.5, 0.5f)];
        scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        scaleAnimation.springBounciness = 20.0f;
        scaleAnimation.springSpeed = 20.0f;
        [self.avatarLayer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
    }
    

}

- (void)setBaseRingStrokeWidth:(CGFloat)strokeWidth
{
    _baseRingStrokeWidth = strokeWidth;
    self.outerRingBaseLayer.lineWidth = _baseRingStrokeWidth;
    [self.layer layoutSublayers];
}

- (void)setProgressRingStrokeWidth:(CGFloat)strokeWidth
{
    _progressRingStrokeWidth = strokeWidth;
    self.currentProgressLayer.lineWidth = _progressRingStrokeWidth;
    [self.layer layoutSublayers];
}


- (void)setProgressStrokeColor:(UIColor *)strokeColor
{
    _progressStrokeColor = strokeColor;
    self.currentProgressLayer.strokeColor = _progressStrokeColor.CGColor;
    [self.layer layoutSublayers];
    
    
}

- (void)setBackgroundLayerColor:(UIColor *)color
{
    _backgroundLayerColor = color;
    self.backgroundLayer.fillColor = _backgroundLayerColor.CGColor;
    [self.layer layoutSublayers];
    
}


#pragma mark - update indicator
- (void)updateWithTotalBytes:(CGFloat)bytes downloadedBytes:(CGFloat)downloadedBytes
{
    
    BOOL previousDisableActionsValue = [CATransaction disableActions];
    [CATransaction setDisableActions:YES];
    
    self.currentProgressLayer.strokeEnd = downloadedBytes/bytes;
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration = 0.5;
    animateStrokeEnd.fromValue = @(self.previousValue);
    animateStrokeEnd.toValue = [NSNumber numberWithFloat:downloadedBytes/bytes];
    animateStrokeEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.currentProgressLayer addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
    
    [CATransaction setDisableActions:previousDisableActionsValue];
    
    self.previousValue = downloadedBytes/bytes;
    
}



@end
