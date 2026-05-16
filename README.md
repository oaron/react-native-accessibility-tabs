# react-native-accessibility-tabs

Properly accessible tab bar primitives for React Native — fixes the iOS VoiceOver and Android TalkBack gaps that React Native's built-in `accessibilityRole="tablist"` falls into.

> **Fabric (New Architecture) only.** This package does not support the legacy architecture.

## Why this exists

React Native's documented tab role behaves inconsistently in production:

- **iOS VoiceOver** sometimes announces "tab" and sometimes nothing — there is no reliable way to express `UIAccessibilityTraitTabBar`, `accessibilityContainerType = .semanticGroup`, or a recursive `accessibilityElements` walk through React Native's deeply nested view hierarchy from JavaScript.
- **Android TalkBack** has no automatic "1 of 5" position announcement, because RN does not expose `CollectionInfo` / `CollectionItemInfo` from `AccessibilityNodeInfo`.

This package ships a Fabric component view on iOS that configures all three traits at the UIView level, plus a JavaScript hook that fills the Android position gap with `accessibilityHint`.

For background see Vispero/TPGI: <https://vispero.com/resources/mobile-tabs-part-2-react-native/>

## Install

```bash
npm install react-native-accessibility-tabs
cd ios && pod install
```

Requires `react-native >= 0.74` with the new architecture enabled (`RCT_NEW_ARCH_ENABLED=1`).

## Usage

```tsx
import { AccessibleTabBar, useAccessibleTabProps } from 'react-native-accessibility-tabs';
import { TouchableOpacity, Text, View } from 'react-native';

function MyTabs({ routes, activeIndex, onSelect }) {
  return (
    <AccessibleTabBar label="Tab bar">
      <View style={{ flexDirection: 'row' }}>
        {routes.map((route, index) => (
          <Tab
            key={route.key}
            label={route.label}
            index={index}
            total={routes.length}
            selected={index === activeIndex}
            onPress={() => onSelect(index)}
          />
        ))}
      </View>
    </AccessibleTabBar>
  );
}

function Tab({ label, index, total, selected, onPress }) {
  const a11yProps = useAccessibleTabProps({ index, total, selected, label });
  return (
    <TouchableOpacity onPress={onPress} {...a11yProps}>
      <Text accessible={false} importantForAccessibility="no">
        {label}
      </Text>
    </TouchableOpacity>
  );
}
```

### `<AccessibleTabBar>`

| Prop       | Type     | Required | Notes                                                                                                   |
| ---------- | -------- | -------- | ------------------------------------------------------------------------------------------------------- |
| `label`    | `string` | yes      | Localized container label. Announced by iOS VoiceOver when focus first enters the tab bar group.        |
| `children` | node     | yes      | Your tab UI. The component does not render any tabs itself — it only configures container a11y traits. |

All other `ViewProps` (style, testID, etc.) are forwarded.

### `useAccessibleTabProps({ index, total, selected, label })`

Returns the platform-correct `accessibility*` props to spread onto each tab button. On iOS, it omits `accessibilityRole` so the parent's `.tabBar` trait can propagate "Tab, X of Y" automatically. On Android, it sets `accessibilityRole="tab"` and emits a manual `${index+1}/${total}` hint.

Pass `positionHint: (i, n) => string` to localize the Android hint format.

## What VoiceOver / TalkBack actually announce

**iOS VoiceOver (with the package):**
- On entering the tab bar group: speaks the `label` prop ("Tab bar", "Lapsor", …).
- On each tab: speaks the tab's `accessibilityLabel`, then "Tab, X of Y", then selected state if applicable.

**Android TalkBack (with the package):**
- On each tab: speaks the tab's label, then "Tab", then the manual position hint ("1/5"), then selected state.
- The container `label` is accepted but **not** currently announced as a group label (Android needs native `CollectionInfo` wiring — planned for v0.2).

## Known gaps

- Android `CollectionInfo` / `CollectionItemInfo` is not yet wired natively — Android container label and automatic position counting are absent. v0.2.
- Legacy (bridge) architecture is not supported. Old-arch projects can keep using the per-app Expo config plugin pattern this package was extracted from.

## License

MIT
