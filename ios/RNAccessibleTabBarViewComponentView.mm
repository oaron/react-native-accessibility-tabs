#import "RNAccessibleTabBarViewComponentView.h"

#import <react/renderer/components/RNAccessibilityTabsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/EventEmitters.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/Props.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation RNAccessibleTabBarViewComponentView {
  BOOL _didEmitMountState;
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

// Match only `isAccessibilityElement=YES`. Including views that merely have an
// `accessibilityLabel` is unsafe — Fabric's `RCTViewComponentView.accessibilityLabel`
// getter recursively concatenates descendant labels when the view is itself an
// accessibility element, so intermediate wrappers can spuriously short-circuit
// the walk.
- (void)collectAccessibleChildrenFrom:(UIView *)view into:(NSMutableArray *)elements
{
  for (UIView *subview in view.subviews) {
    if (subview.isHidden || subview.accessibilityElementsHidden) {
      continue;
    }
    if (subview.isAccessibilityElement) {
      [elements addObject:subview];
    } else {
      [self collectAccessibleChildrenFrom:subview into:elements];
    }
  }
}

#pragma mark - Debug (event to JS)

// Native RCTLogWarn doesn't reliably forward to Metro in bridgeless mode
// (Expo SDK 54 / RN 0.81), so we emit the state as a JS event instead — that
// always rides the standard React event channel and reaches the JS console.
// Retries each layout pass until _eventEmitter is non-null (Fabric sets it
// via updateEventEmitter, which may run *after* the first layoutSubviews).
- (void)layoutSubviews
{
  [super layoutSubviews];
  if (_didEmitMountState) {
    return;
  }
  if (_eventEmitter == nullptr) {
    return;
  }
  _didEmitMountState = YES;
  [self emitMountState];
}

- (void)emitMountState
{
  if (_eventEmitter == nullptr) {
    return;
  }
  NSMutableArray *walked = [NSMutableArray array];
  [self collectAccessibleChildrenFrom:self into:walked];

  NSString *traitsHex = [NSString stringWithFormat:@"0x%llx", (unsigned long long)self.accessibilityTraits];
  NSString *labelStr = self.accessibilityLabel ?: @"";

  auto emitter = std::static_pointer_cast<const RNAccessibleTabBarViewEventEmitter>(_eventEmitter);
  emitter->onMountState({
    .isAccessibilityElement = static_cast<bool>(self.isAccessibilityElement),
    .accessibilityLabel = std::string(labelStr.UTF8String ?: ""),
    .accessibilityTraits = std::string(traitsHex.UTF8String ?: ""),
    .containerType = static_cast<int>(self.accessibilityContainerType),
    .subviewCount = static_cast<int>(self.subviews.count),
    .walkedChildrenCount = static_cast<int>(walked.count),
  });
}

@end

Class<RCTComponentViewProtocol> RNAccessibleTabBarViewCls(void)
{
  return RNAccessibleTabBarViewComponentView.class;
}
