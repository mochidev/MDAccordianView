//
//  MDAccordianView.m
//  MDAccordianViewDemo
//
//  Created by Dimitri Bouniol on 5/4/12.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//
//  Copyright (c) 2012 Dimitri Bouniol, Mochi Development, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software, associated artwork, and documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  1. The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//  2. Neither the name of Mochi Development, Inc. nor the names of its
//     contributors or products may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//

#import "MDAccordianView.h"
#import <QuartzCore/CoreAnimation.h>

@interface MDAccordianFoldView : UIView {
    UIImageView *backgroundImage;
    UIImageView *shadeImage;
}

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *shadeImage;

@end

@implementation MDAccordianFoldView

@synthesize backgroundImage, shadeImage;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundImage];
        backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        shadeImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:shadeImage];
        shadeImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.clipsToBounds = YES;
    }
    return self;
}

@end

@interface MDAccordianView ()

@property (nonatomic, readwrite) NSUInteger numberOfFolds;
@property (nonatomic, strong) UIImage *cachedImage;

- (void)generateCachedImage;

@end

@implementation MDAccordianView

@synthesize numberOfFolds, naturalSize, contentView, cachedImage;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame folds:2];
}

- (id)initWithFrame:(CGRect)frame folds:(NSUInteger)folds;
{
    if (self = [super initWithFrame:frame]) {
        self.naturalSize = frame.size;
        self.numberOfFolds = folds;
        
        CATransform3D perspectiveTransform = CATransform3DIdentity;
        perspectiveTransform.m34 = 1.0 / -1000;
        self.layer.sublayerTransform = perspectiveTransform;
    }
    return self;
}

- (void)setNumberOfFolds:(NSUInteger)folds
{
    numberOfFolds = folds;
    
    for (UIView *view in foldViews) {
        [view removeFromSuperview];
    }
    
    foldViews = [[NSMutableArray alloc] init];
    
    NSUInteger totalFolds = (numberOfFolds+1)*2;
    CGFloat foldHeight = naturalSize.height/totalFolds;
    
    for (NSUInteger i = 0; i < totalFolds; i++) {
        MDAccordianFoldView *fold = [[MDAccordianFoldView alloc] initWithFrame:CGRectMake(0, i*foldHeight, self.bounds.size.width, foldHeight)];
        fold.backgroundColor = [UIColor greenColor];
        fold.backgroundImage.frame = CGRectMake(0, -i*foldHeight, self.bounds.size.width, foldHeight);
        [self insertSubview:fold atIndex:0];
        [foldViews addObject:fold];
        
        fold.layer.anchorPoint = CGPointMake(0.5, i%2);
    }
    
    [self generateCachedImage];
    [self layoutIfNeeded];
}

- (UIView *)contentView
{
    if (!contentView) {
        contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:contentView];
    }
    
    return contentView;
}

- (void)setContentView:(UIView *)aView
{
    [contentView removeFromSuperview];
    contentView = aView;
    [self addSubview:aView];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    if (self.frame.size.height >= naturalSize.height) {
        contentView.hidden = NO;
        contentView.frame = self.bounds;
        generatedImage = NO;
    } else {
        if (!generatedImage) {
            generatedImage = YES;
            
            [self generateCachedImage];
        }
        
        contentView.hidden = YES;
        
        BOOL flipped = NO;
        
        NSUInteger index = 0;
        
        for (MDAccordianFoldView *fold in foldViews) {
            CGFloat oposite = self.frame.size.height/foldViews.count;
            CGFloat hypotenus = fold.bounds.size.height;
            CGFloat adjacent = sqrtf(hypotenus*hypotenus - ceilf(oposite+1)*ceilf(oposite+1));
            
            fold.layer.bounds = CGRectMake(0, 0, self.frame.size.width, fold.bounds.size.height);
            
            if (!flipped) {
                fold.layer.transform = CATransform3DMakeRotation(-M_PI_2+atanf(oposite/adjacent), 1, 0, 0);
                fold.layer.position = CGPointMake(self.frame.size.width/2., roundf(2.*oposite*floorf(index/2.)));
            } else {
                fold.layer.transform = CATransform3DMakeRotation(M_PI_2-atanf(oposite/adjacent), 1, 0, 0);
                fold.layer.position = CGPointMake(self.frame.size.width/2., roundf(2.*oposite*ceilf(index/2.)));
            }
            
            flipped = !flipped;
            index++;
        }
    }
}

- (void)generateCachedImage
{
    CGRect oldRect = self.contentView.frame;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (!CGSizeEqualToSize(oldRect.size, naturalSize)) {
        self.contentView.frame = CGRectMake(oldRect.origin.x, oldRect.origin.y, naturalSize.width, naturalSize.height);
    }
    
    UIGraphicsBeginImageContext(naturalSize);
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.cachedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.contentView.frame = oldRect;
    
    [CATransaction commit];
    
    for (MDAccordianFoldView *fold in foldViews) {
        fold.backgroundImage.image = self.cachedImage;
    }
}

@end
