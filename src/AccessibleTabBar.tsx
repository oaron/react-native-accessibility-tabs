import React from 'react';
import { Platform, View, type ViewProps, type NativeSyntheticEvent } from 'react-native';
import RNAccessibleTabBarView, {
  type AccessibleTabBarStateEvent,
} from './AccessibleTabBarNativeComponent';

export interface AccessibleTabBarProps extends Omit<ViewProps, 'accessibilityRole'> {
  /**
   * The label VoiceOver announces when focus first enters the tab bar group on iOS
   * (e.g. "Tab bar", "Lapsor", "Onglet"). Required — there is no sensible cross-locale
   * default, and without it the iOS group announcement does not fire.
   *
   * On Android the label is accepted but currently not announced by TalkBack as a
   * group label (a native CollectionInfo wiring is planned for a future release).
   */
  label: string;
  /**
   * Debug only: log the native view's accessibility state once after first mount.
   * Useful when the announcement isn't what you expect.
   */
  debug?: boolean;
  children: React.ReactNode;
}

export const AccessibleTabBar: React.FC<AccessibleTabBarProps> = ({
  label,
  debug,
  children,
  ...rest
}) => {
  if (Platform.OS === 'ios') {
    const onMountState = debug
      ? (e: NativeSyntheticEvent<AccessibleTabBarStateEvent>) => {
          // eslint-disable-next-line no-console
          console.warn(
            '[AccessibleTabBar] native state:',
            JSON.stringify(e.nativeEvent),
          );
        }
      : undefined;
    return (
      <RNAccessibleTabBarView
        accessibilityLabel={label}
        onMountState={onMountState}
        {...rest}
      >
        {children as React.ReactElement}
      </RNAccessibleTabBarView>
    );
  }
  return (
    <View accessibilityRole="list" {...rest}>
      {children}
    </View>
  );
};
