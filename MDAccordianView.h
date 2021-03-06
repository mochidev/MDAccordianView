//
//  MDAccordianView.h
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

#import <UIKit/UIKit.h>

@interface MDAccordianView : UIView {
    NSUInteger numberOfFolds;
    CGSize naturalSize;
    
    NSMutableArray *foldViews;
    UIView *contentView;
    
    UIImage *cachedImage;
    
    BOOL generatedImage;
    
    CGFloat distanceFromScreen;
}

@property (nonatomic) CGSize naturalSize; // the size at which the view will not be folded and be operational
@property (nonatomic) CGFloat distanceFromScreen; // set to a positive value, in pixels, of the users face from the screen;
@property (readonly, nonatomic) NSUInteger numberOfFolds;
@property (nonatomic, strong) UIView *contentView; // don't add subviews directly!! set this or add to this instead

- (id)initWithFrame:(CGRect)frame folds:(NSUInteger)folds; // set the number of central peaks for the folding

- (void)setFrame:(CGRect)frame animated:(BOOL)animated;

@end
