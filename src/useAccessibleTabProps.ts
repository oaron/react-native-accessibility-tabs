import { Platform } from 'react-native';
import type { AccessibilityProps, AccessibilityRole, AccessibilityState } from 'react-native';

export interface UseAccessibleTabPropsArgs {
  index: number;
  total: number;
  selected: boolean;
  label: string;
  /**
   * Customize the Android-only position hint TalkBack reads after the tab label.
   * Receives 1-based index and total; returns the string passed to accessibilityHint.
   * Default: `${index}/${total}`.
   */
  positionHint?: (index1Based: number, total: number) => string;
}

export interface AccessibleTabProps {
  accessibilityRole?: AccessibilityRole;
  accessibilityLabel: string;
  accessibilityState: AccessibilityState;
  accessibilityHint?: string;
}

const defaultPositionHint = (index1Based: number, total: number): string =>
  `${index1Based}/${total}`;

/**
 * Returns the platform-correct accessibility props for an individual tab inside
 * an `<AccessibleTabBar>`.
 *
 * iOS: leaves accessibilityRole undefined (the parent's `.tabBar` trait already
 * propagates "Tab, X of Y" to each focusable child — overriding role would break it).
 *
 * Android: sets accessibilityRole="tab" and supplies a manual "1/N" hint, because
 * RN does not currently expose Android's CollectionItemInfo for automatic counting.
 */
export function useAccessibleTabProps(args: UseAccessibleTabPropsArgs): AccessibleTabProps &
  Pick<AccessibilityProps, 'accessibilityRole' | 'accessibilityLabel' | 'accessibilityState' | 'accessibilityHint'> {
  const { index, total, selected, label, positionHint } = args;
  const isAndroid = Platform.OS === 'android';
  return {
    accessibilityRole: isAndroid ? 'tab' : undefined,
    accessibilityLabel: label,
    accessibilityState: { selected },
    accessibilityHint: isAndroid
      ? (positionHint ?? defaultPositionHint)(index + 1, total)
      : undefined,
  };
}
