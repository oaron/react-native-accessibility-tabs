# Changelog

## [0.1.7]

### Fixed
- iOS: `accessibilityElements` walker no longer matches on `accessibilityLabel.length > 0`. Fabric's `RCTViewComponentView.accessibilityLabel` getter recursively concatenates descendant labels when the view is itself an accessibility element, so an intermediate wrapper could spuriously match and short-circuit the walk — leaving the actual tab buttons hidden from VoiceOver. The walk now matches only `isAccessibilityElement=YES`, aligned with the original Swift reference implementation.

## [Unreleased]

### Added
- Initial `<AccessibleTabBar>` Fabric component (iOS): `UIAccessibilityTraitTabBar`, `accessibilityContainerType = .semanticGroup`, recursive `accessibilityElements` walk.
- `useAccessibleTabProps()` hook returning per-tab accessibility props with Android position hint.
- Pure-JS Android container (`accessibilityRole="list"`).
