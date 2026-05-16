#import "RNAccessibleTabBarViewComponentView.h"

#import <React/RCTLog.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/EventEmitters.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/Props.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

// Toggle this to NO before publishing a non-debug release.
static const BOOL kAccessibleTabBarDebugOverlay = YES;

@implementation RNAccessibleTabBarViewComponentView {
  UILabel *_debugOverlay;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RNAccessibleTabBarViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNAccessibleTabBarViewProps>();
    _props = defaultProps;

    if (kAccessibleTabBarDebugOverlay) {
      _debugOverlay = [[UILabel alloc] init];
      _debugOverlay.numberOfLines = 0;
      _debugOverlay.font = [UIFont monospacedSystemFontOfSize:9 weight:UIFontWeightRegular];
      _debugOverlay.textColor = [UIColor whiteColor];
      _debugOverlay.backgroundColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:0.85];
      _debugOverlay.textAlignment = NSTextAlignmentLeft;
      _debugOverlay.accessibilityElementsHidden = YES;
      _debugOverlay.isAccessibilityElement = NO;
      _debugOverlay.userInteractionEnabled = NO;
      _debugOverlay.text = @"v0.1.3 init";
      [self addSubview:_debugOverlay];
    }
  }
  return self;
}

#pragma mark - Accessibility (getter overrides)

- (BOOL)isAccessibilityElement
{
  return NO;
}

- (UIAccessibilityTraits)accessibilityTraits
{
  return [super accessibilityTraits] | UIAccessibilityTraitTabBar;
}

- (UIAccessibilityContainerType)accessibilityContainerType
{
  if (@available(iOS 13.0, *)) {
    return UIAccessibilityContainerTypeSemanticGroup;
  }
  return UIAccessibilityContainerTypeNone;
}

- (NSArray *)accessibilityElements
{
  NSMutableArray *elements = [NSMutableArray array];
  [self collectAccessibleChildrenFrom:self into:elements];
  return elements.count > 0 ? elements : nil;
}

- (void)collectAccessibleChildrenFrom:(UIView *)view into:(NSMutableArray *)elements
{
  for (UIView *subview in view.subviews) {
    if (subview == _debugOverlay) {
      continue;
    }
    if (subview.isHidden || subview.accessibilityElementsHidden) {
      continue;
    }
    if (subview.isAccessibilityElement || subview.accessibilityLabel.length > 0) {
      [elements addObject:subview];
    } else {
      [self collectAccessibleChildrenFrom:subview into:elements];
    }
  }
}

#pragma mark - Debug

- (void)layoutSubviews
{
  [super layoutSubviews];

  if (kAccessibleTabBarDebugOverlay) {
    _debugOverlay.frame = CGRectMake(0, 0, self.bounds.size.width, 80);
    [self bringSubviewToFront:_debugOverlay];
    [self refreshDebugOverlay];
  }

  static dispatch_once_t once;
  dispatch_once(&once, ^{
    RCTLogWarn(@"[AccessibleTabBar] v0.1.3 first layout — class=%@ subviews=%lu label='%@' traits=0x%llx elem=%d",
               NSStringFromClass(self.class),
               (unsigned long)self.subviews.count,
               self.accessibilityLabel ?: @"(nil)",
               (unsigned long long)self.accessibilityTraits,
               self.isAccessibilityElement);
    [self dumpTreeFrom:self depth:0];
  });
}

- (void)refreshDebugOverlay
{
  if (!_debugOverlay) {
    return;
  }
  NSMutableArray *walked = [NSMutableArray array];
  [self collectAccessibleChildrenFrom:self into:walked];
  _debugOverlay.text = [NSString stringWithFormat:
      @"v0.1.3  class=%@\n"
      @"isAccessibilityElement=%d\n"
      @"traits=0x%llx (tabBar=0x%llx)\n"
      @"label='%@'\n"
      @"subviews=%lu  walked-children=%lu",
      NSStringFromClass(self.class),
      self.isAccessibilityElement,
      (unsigned long long)self.accessibilityTraits,
      (unsigned long long)UIAccessibilityTraitTabBar,
      self.accessibilityLabel ?: @"(nil)",
      (unsigned long)self.subviews.count,
      (unsigned long)walked.count];
}

- (void)dumpTreeFrom:(UIView *)view depth:(NSInteger)depth
{
  NSString *pad = [@"" stringByPaddingToLength:(NSUInteger)depth * 2
                                   withString:@" "
                              startingAtIndex:0];
  RCTLogWarn(@"[AccessibleTabBar] %@%@ a11yElem=%d label='%@' traits=0x%llx",
             pad,
             NSStringFromClass(view.class),
             view.isAccessibilityElement,
             view.accessibilityLabel ?: @"",
             (unsigned long long)view.accessibilityTraits);
  if (depth > 12) {
    return;
  }
  for (UIView *child in view.subviews) {
    if (child == _debugOverlay) {
      continue;
    }
    [self dumpTreeFrom:child depth:depth + 1];
  }
}

@end

Class<RCTComponentViewProtocol> RNAccessibleTabBarViewCls(void)
{
  return RNAccessibleTabBarViewComponentView.class;
}
