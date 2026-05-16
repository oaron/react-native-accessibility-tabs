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
  children: React.ReactNode;
}

export const AccessibleTabBar: React.FC<AccessibleTabBarProps> = ({
  label,
  children,
  ...rest
}) => {
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
