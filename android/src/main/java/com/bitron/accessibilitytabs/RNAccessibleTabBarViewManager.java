package com.bitron.accessibilitytabs;

import androidx.annotation.NonNull;

import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

public class RNAccessibleTabBarViewManager extends ViewGroupManager<RNAccessibleTabBarView> {

  public static final String REACT_CLASS = "RNAccessibleTabBarView";

  @NonNull
  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @NonNull
  @Override
  protected RNAccessibleTabBarView createViewInstance(@NonNull ThemedReactContext reactContext) {
    return new RNAccessibleTabBarView(reactContext);
  }
}
