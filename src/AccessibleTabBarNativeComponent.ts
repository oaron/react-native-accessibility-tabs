import { requireNativeComponent } from 'react-native';
import type { HostComponent, ViewProps } from 'react-native';

export interface NativeProps extends ViewProps {}

const RNAccessibleTabBarView =
  requireNativeComponent<NativeProps>('RNAccessibleTabBarView') as HostComponent<NativeProps>;

export default RNAccessibleTabBarView;
