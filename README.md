# react-native-accessibility-tabs

Properly accessible tab bar primitives for React Native. Fixes the iOS VoiceOver and Android TalkBack gaps that React Native's documented `accessibilityRole="tablist"` cannot reach from JavaScript.

- **iOS:** native Swift `UIView` with `UIAccessibilityTraitTabBar`, `accessibilityContainerType = .semanticGroup`, and a recursive `accessibilityElements` walk that finds the actual tab buttons buried under RN's nested `RCTView` wrappers.
- **Android:** native `ReactViewGroup` that sets `CollectionInfoCompat` on the container and `CollectionItemInfoCompat` on each tab descendant — so TalkBack gets the structural "1 of N" / "selected" context for free.
- **Architecture-agnostic:** legacy bridge view manager, interop-wrapped automatically on new-arch (Fabric) apps. No codegen, no `RCT_NEW_ARCH_ENABLED` requirement.
- **Navigator-agnostic:** works with React Navigation, Expo Router, `react-native-tab-view`, or hand-rolled `useState` tabs. The library only configures container traits and per-tab a11y props.

## Why this exists

React Native's documented tab role behaves inconsistently in production:

- **iOS VoiceOver** sometimes announces "tab" and sometimes nothing. There is no JS-level way to express `UIAccessibilityTraitTabBar`, `accessibilityContainerType = .semanticGroup`, or a recursive `accessibilityElements` walk through React Native's deeply nested view hierarchy.
- **Android TalkBack** has no automatic "1 of 5" position announcement because RN does not expose `CollectionInfoCompat` / `CollectionItemInfoCompat` from `AccessibilityNodeInfo`.

This package ships the native pieces for both platforms.

Background: Vispero/TPGI — <https://vispero.com/resources/mobile-tabs-part-2-react-native/>.

## Install

```bash
npm install react-native-accessibility-tabs
cd ios && pod install
```

Peer dependencies: `react-native >= 0.74`, `react >= 18`. iOS 13+, Android `minSdkVersion >= 24` (Android API 24 / 7.0+). Both legacy and new architecture supported.

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

The `label` is what VoiceOver announces when focus first enters the tab bar group on iOS. Localize it — there is no sensible cross-locale default (English "Tab bar", Hungarian "Lapsor", French "Onglet", …).

**Do not** set `accessible={true}` on the wrapper or on any inner row View — that collapses the children into a single focus node and tab navigation breaks.

### `<AccessibleTabBar>`

| Prop       | Type     | Required | Notes                                                                                              |
| ---------- | -------- | -------- | -------------------------------------------------------------------------------------------------- |
| `label`    | `string` | yes      | Localized container label. iOS VoiceOver announces it when focus first enters the tab bar group.   |
| `children` | node     | yes      | Your tab UI. The component does not render any tabs itself — it only configures container traits.  |
| `debug`    | `boolean`| no       | Log a mount line to the Metro console.                                                              |

All other `ViewProps` (style, testID, etc.) are forwarded.

### `useAccessibleTabProps({ index, total, selected, label, positionHint? })`

Returns the platform-correct `accessibility*` props to spread onto each tab button.

- **iOS:** omits `accessibilityRole` so the parent's `.tabBar` trait can propagate "Tab, X of Y" automatically.
- **Android:** sets `accessibilityRole="tab"` and emits a manual `${index+1}/${total}` `accessibilityHint`. The native `CollectionItemInfo` already provides structural position to TalkBack; the manual hint is kept as an audible reinforcement that works on all TalkBack versions. Pass `positionHint: (i, n) => ''` to disable, or `positionHint: (i, n) => \`${i} of ${n}\`` to customize.

## What VoiceOver / TalkBack announce

**iOS VoiceOver:**
- On entering the tab bar group: speaks the `label` prop.
- On each tab: speaks the tab's `accessibilityLabel`, then "Tab, X of Y", then selected state.

**Android TalkBack:**
- On each tab: speaks the tab's label, then "Tab", then the position hint, then selected state.
- TalkBack uses the native `CollectionInfo` / `CollectionItemInfo` to provide structural context (single-selection collection of N items).

## Use with React Navigation

The package is navigator-agnostic, but a common integration with `@react-navigation/bottom-tabs` is:

```tsx
import { createBottomTabNavigator, type BottomTabBarProps } from '@react-navigation/bottom-tabs';
import { AccessibleTabBar, useAccessibleTabProps } from 'react-native-accessibility-tabs';

function CustomTabBar({ state, descriptors, navigation }: BottomTabBarProps) {
  return (
    <AccessibleTabBar label="Tab bar">
      <View style={{ flexDirection: 'row' }}>
        {state.routes.map((route, index) => {
          const label = descriptors[route.key].options.title ?? route.name;
          const selected = index === state.index;
          const a11yProps = useAccessibleTabProps({ index, total: state.routes.length, selected, label });
          return (
            <TouchableOpacity
              key={route.key}
              onPress={() => navigation.navigate(route.name)}
              {...a11yProps}
            >
              <Text accessible={false} importantForAccessibility="no">{label}</Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </AccessibleTabBar>
  );
}

<Tab.Navigator tabBar={(props) => <CustomTabBar {...props} />}>
  {/* … */}
</Tab.Navigator>
```

Pass the `tabBar` prop as a **render function**, not a component reference. RN-nav invokes it as `tabBar(props)`, and passing the component bypasses React render — hooks then fail with "Invalid hook call".

## License

MIT
