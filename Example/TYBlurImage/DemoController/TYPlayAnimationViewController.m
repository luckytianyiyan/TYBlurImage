//
//  TYPlayAnimationViewController.m
//
//  Copyright (c) 2015 luckytianyiyan (http://tianyiyan.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TYPlayAnimationViewController.h"
#import "UIImageView+BlurAnimation.h"
#import "TYDemoSwitch.h"
#import "TYDemoSlider.h"
#import <Masonry.h>

static CGFloat const kSliderHeight = 40.f;

static CGFloat const kLabelHeight = 30.f;
static CGFloat const kSwitchHeight = 30.f;

#define kTintColor [UIColor colorWithWhite:1.0 alpha:0.3]


@interface TYPlayAnimationViewController ()

@property (nonatomic, strong) TYDemoSwitch *tintColorSwitch;
@property (nonatomic, strong) TYDemoSwitch *repeatForeverSwitch;
@property (nonatomic, strong) TYDemoSwitch *downsampleSwitch;

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, assign) BOOL isNeedRegenerateBlurFrames;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) TYDemoSlider *radiusSlider;
@property (nonatomic, strong) TYDemoSlider *framesCountSlider;

@property (nonatomic, strong) UILabel *radiusValueLabel;
@property (nonatomic, strong) UILabel *framesCountValueLabel;

@property (nonatomic, strong) UIButton *playAnimationButton;

@end

@implementation TYPlayAnimationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Animation";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _contentScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_contentScrollView];
    
    _playAnimationButton = [[UIButton alloc] init];
    [_playAnimationButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playAnimationButton addTarget:self action:@selector(onPlayAnimationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_playAnimationButton setTitle:@"Play AnimationButton" forState:UIControlStateNormal];
    [_contentScrollView addSubview:_playAnimationButton];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lena.jpg"]];
    _imageView.animationRepeatCount = 1;
    [_contentScrollView addSubview:_imageView];
    
    _radiusSlider = [[TYDemoSlider alloc] init];
    _radiusSlider.slider.maximumValue = 100;
    _radiusSlider.title = @"Radius";
    [_radiusSlider.slider addTarget:self action:@selector(onRadiusSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_contentScrollView addSubview:_radiusSlider];
    
    _framesCountSlider = [[TYDemoSlider alloc] init];
    _framesCountSlider.slider.maximumValue = 100;
    _framesCountSlider.title = @"Frames Count";
    [_framesCountSlider.slider addTarget:self action:@selector(onFramesCountSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_contentScrollView addSubview:_framesCountSlider];
    
    _tintColorSwitch = [[TYDemoSwitch alloc] init];
    _tintColorSwitch.title = @"Use Tint Color";
    [_tintColorSwitch.contentSwitch addTarget:self action:@selector(onTintColorSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_contentScrollView addSubview:_tintColorSwitch];
    
    _repeatForeverSwitch = [[TYDemoSwitch alloc] init];
    _repeatForeverSwitch.title = @"Repeat Forever";
    [_repeatForeverSwitch.contentSwitch addTarget:self action:@selector(onRepeatForeverSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_contentScrollView addSubview:_repeatForeverSwitch];
    
    _downsampleSwitch = [[TYDemoSwitch alloc] init];
    _downsampleSwitch.on = _imageView.isDownsampleBlurAnimationImage;
    _downsampleSwitch.title = @"Downsample";
    [_downsampleSwitch.contentSwitch addTarget:self action:@selector(onDownsampleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_contentScrollView addSubview:_downsampleSwitch];
    
    [self setupLabels];
    
    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_radiusSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.equalTo(@(kSliderHeight));
    }];
    
    [_framesCountSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.radiusSlider.mas_bottom);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.equalTo(@(kSliderHeight));
    }];
    
    [_tintColorSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.framesCountSlider.mas_bottom);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.equalTo(@(kSwitchHeight));
    }];
    
    [_repeatForeverSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tintColorSwitch.mas_bottom);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.equalTo(@(kSwitchHeight));
    }];
    
    [_downsampleSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.repeatForeverSwitch.mas_bottom);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.equalTo(@(kSwitchHeight));
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentScrollView);
        make.top.equalTo(self.downsampleSwitch.mas_bottom);
    }];
    
    [_radiusValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentScrollView);
        make.top.equalTo(self.imageView.mas_bottom);
        make.width.equalTo(self.contentScrollView).multipliedBy(.5f);
        make.height.equalTo(@(kLabelHeight));
    }];
    
    [_framesCountValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.radiusValueLabel.mas_right);
        make.top.equalTo(self.imageView.mas_bottom);
        make.width.equalTo(self.contentScrollView).multipliedBy(.5f);
        make.height.equalTo(@(kLabelHeight));
    }];
}

#pragma mark - Setup

- (void)setupLabels
{
    _radiusValueLabel = [[UILabel alloc] init];
    _radiusValueLabel.text = [NSString stringWithFormat:@"Radius: %.1f", _radiusSlider.value];
    _radiusValueLabel.textAlignment = NSTextAlignmentCenter;
    [_contentScrollView addSubview:_radiusValueLabel];
    
    _framesCountValueLabel = [[UILabel alloc] init];
    _framesCountValueLabel.text = [NSString stringWithFormat:@"Frames Count: %ld", (long)_framesCountSlider.value];
    _framesCountValueLabel.textAlignment = NSTextAlignmentCenter;
    [_contentScrollView addSubview:_framesCountValueLabel];

    [_playAnimationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.top.equalTo(self.radiusValueLabel.mas_bottom);
        make.bottom.equalTo(self.contentScrollView);
    }];
}

#pragma mark - Event Response

- (void)onDownsampleSwitchValueChanged:(UISwitch *)sender
{
    _imageView.downsampleBlurAnimationImage = sender.isOn;
    _isNeedRegenerateBlurFrames = YES;
}

- (void)onRepeatForeverSwitchValueChanged:(UISwitch *)sender
{
    /**
     *  set animationRepeatCount need not generate frames
     */
    _imageView.animationRepeatCount = sender.isOn ? 0 : 1;
}

- (void)onTintColorSwitchValueChanged:(UISwitch *)sender
{
    _imageView.blurTintColor = sender.isOn ? kTintColor : nil;
    _isNeedRegenerateBlurFrames = YES;
}

- (void)onFramesCountSliderValueChanged:(UISlider *)sender
{
    _framesCountValueLabel.text = [NSString stringWithFormat:@"Frames Count: %ld", (long)sender.value];
    _imageView.framesCount = (NSInteger)sender.value;
    _isNeedRegenerateBlurFrames = YES;
}

- (void)onRadiusSliderValueChanged:(UISlider *)sender
{
    _radiusValueLabel.text = [NSString stringWithFormat:@"Radius: %.1f", sender.value];
    _imageView.blurRadius = sender.value;
    _isNeedRegenerateBlurFrames = YES;
}

- (void)onPlayAnimationButtonClicked:(UIButton *)sender
{
    if (_isNeedRegenerateBlurFrames) {
        NSLog(@"radius or framesCount has changed. regenerate frames.");
        [_imageView ty_generateBlurFramesWithCompletion:^{
            NSLog(@"regenerate frames end.");
            _isNeedRegenerateBlurFrames = NO;
            [_imageView ty_blurInAnimationWithDuration:0.25f completion:^{
                NSLog(@"Animation End");
            }];
        }];
    } else {
        [_imageView ty_blurInAnimationWithDuration:0.25f completion:^{
            NSLog(@"Animation End");
        }];
    }
    
}

@end
