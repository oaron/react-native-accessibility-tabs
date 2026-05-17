# react-native-accessibility-tabs

Properly accessible tab bar primitives for React Native — fixes the iOS VoiceOver and Android TalkBack gaps that React Native's built-in `accessibilityRole="tablist"` falls into.

Works with **legacy and new architecture** Expo / React Native apps. On new-arch, the legacy view manager is interop-wrapped by Fabric automatically.

## Why this exists

React Native's documented tab role behaves inconsistently in production:

- **iOS VoiceOver** sometimes announces "tab" and sometimes nothing — there is no reliable way to express `UIAccessibilityTraitTabBar`, `accessibilityContainerType = .semanticGroup`, or a recursive `accessibilityElements` walk through React Native's deeply nested view hierarchy from JavaScript.
- **Android TalkBack** has no automatic "1 of 5" position announcement, because RN does not expose `CollectionInfo` / `CollectionItemInfo` from `AccessibilityNodeInfo`.

This package ships a native iOS `UIView` (Swift) that configures all three traits at the UIView level, plus a JavaScript hook that fills the Android position gap with `accessibilityHint`.

For background see Vispero/TPGI: <https://vispero.com/resources/mobile-tabs-part-2-react-native/>

## Install

```bash
npm install react-native-accessibility-tabs
cd ios && pod install
```

`react-native >= 0.74`. Works without `RCT_NEW_ARCH_ENABLED`; on new arch the native view is interop-wrapped automatically.

## Usage

`<AccessibleTabBar>` only configures the container's accessibility traits — it does **not** render any tabs itself. Use any tab UI you like (React Navigation, Expo Router, manual `useState`, `react-native-tab-view`, …).

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
| `debug`    | `boolean`| no       | Log a mount line to the Metro console.                                                                  |

All other `ViewProps` (style, testID, etc.) are forwarded.

**Do not** set `accessible={true}` on the wrapper or any inner row View — that collapses the children into a single focus node and the tab navigation breaks.

### `useAccessibleTabProps({ index, total, selected, label })`

Returns the platform-correct `accessibility*` props to spread onto each tab button. On iOS, it omits `accessibilityRole` so the parent's `.tabBar` trait can propagate "Tab, X of Y" automatically. On Android, it sets `accessibilityRole="tab"` and emits a manual `${index+1}/${total}` hint.

Pass `positionHint: (i, n) => string` to localize the Android hint format.

## What VoiceOver / TalkBack actually announce

**iOS VoiceOver:**
- On entering the tab bar group: speaks the `label` prop ("Tab bar", "Lapsor", …).
- On each tab: speaks the tab's `accessibilityLabel`, then "Tab, X of Y", then selected state if applicable.

**Android TalkBack:**
- On each tab: speaks the tab's label, then "Tab", then the manual position hint ("1/5"), then selected state.
- The container `label` is accepted but **not** currently announced as a group label (Android needs native `CollectionInfo` wiring — planned for v0.2).

## Use with React Navigation

The package is navigator-agnostic, but if you wire it into `@react-navigation/bottom-tabs`, the pattern looks like:

```tsx
import { createBottomTabNavigator, type BottomTabBarProps } from '@react-navigation/bottom-tabs';

function CustomTabBar({ state, descriptors, navigation }: BottomTabBarProps) {
  return (
    <AccessibleTabBar label="Tab bar">
      <View style={{ flexDirection: 'row' }}>
        {state.routes.map((route, index) => (
          <Tab
            key={route.key}
            label={descriptors[route.key].options.title ?? route.name}
            index={index}
            total={state.routes.length}
            selected={index === state.index}
            onPress={() => navigation.navigate(route.name)}
          />
        ))}
      </View>
    </AccessibleTabBar>
  );
}

<Tab.Navigator tabBar={(props) => <CustomTabBar {...props} />}>
  {/* … */}
</Tab.Navigator>
```

Pass the `tabBar` prop as a **render function**, not a component reference — RN-nav invokes the function as `tabBar(props)`, so passing the component bypasses React render and hooks fail with "Invalid hook call".

## Known gaps

- Android `CollectionInfo` / `CollectionItemInfo` is not yet wired natively — Android container label and automatic position counting are absent. Planned for v0.2.

## License

MIT
