import React from 'react';
import { Platform, View, type ViewProps } from 'react-native';
import RNAccessibleTabBarView from './AccessibleTabBarNativeComponent';

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
   * Debug only: log mount info to the Metro console. Useful when the announcement
   * isn't what you expect.
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
  React.useEffect(() => {
    if (debug) {
      // eslint-disable-next-line no-console
      console.warn(
        `[AccessibleTabBar JS] mount v0.1.8 platform=${Platform.OS} label='${label}'`,
      );
    }
  }, [debug, label]);

  if (Platform.OS === 'ios') {
    return (
      <RNAccessibleTabBarView accessibilityLabel={label} {...rest}>
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
