# Changelog

## [0.1.8]

### Changed (breaking — install path / arch)
- iOS rewritten from Fabric component view (`RCTViewComponentView`, codegen) to legacy bridge view manager (Swift `UIView` + `RCTViewManager` + `RCT_EXTERN_MODULE`). The Fabric component class was not being registered with the Fabric component view registry in real-world Expo builds, so the `.tabBar` trait / `.semanticGroup` / recursive `accessibilityElements` overrides never ran — VoiceOver saw a plain `RCTViewComponentView` fallback and tabs were unreachable.
- The legacy view manager is interop-wrapped automatically by Fabric on new-arch apps, and is a 1:1 port of a proven production implementation. No JS-side API changes — `<AccessibleTabBar label="…">` and `useAccessibleTabProps()` behave the same.
- `codegenConfig` removed from `package.json`. Pods no longer depend on codegen generation.

## [0.1.7]

### Fixed
- iOS: `accessibilityElements` walker no longer matches on `accessibilityLabel.length > 0`. Fabric's `RCTViewComponentView.accessibilityLabel` getter recursively concatenates descendant labels when the view is itself an accessibility element, so an intermediate wrapper could spuriously match and short-circuit the walk — leaving the actual tab buttons hidden from VoiceOver. The walk now matches only `isAccessibilityElement=YES`, aligned with the original Swift reference implementation.

## [Unreleased]

### Added
- Initial `<AccessibleTabBar>` Fabric component (iOS): `UIAccessibilityTraitTabBar`, `accessibilityContainerType = .semanticGroup`, recursive `accessibilityElements` walk.
- `useAccessibleTabProps()` hook returning per-tab accessibility props with Android position hint.
- Pure-JS Android container (`accessibilityRole="list"`).
