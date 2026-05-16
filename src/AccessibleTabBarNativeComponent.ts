import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { HostComponent, ViewProps } from 'react-native';
import type {
  BubblingEventHandler,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

export type AccessibleTabBarStateEvent = Readonly<{
  isAccessibilityElement: boolean;
  accessibilityLabel: string;
  accessibilityTraits: string;
  containerType: Int32;
  subviewCount: Int32;
  walkedChildrenCount: Int32;
}>;

export interface NativeProps extends ViewProps {
  onMountState?: BubblingEventHandler<AccessibleTabBarStateEvent> | null;
}

export default codegenNativeComponent<NativeProps>(
  'RNAccessibleTabBarView',
) as HostComponent<NativeProps>;
