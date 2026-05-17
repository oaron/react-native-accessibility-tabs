package com.bitron.accessibilitytabs;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.view.AccessibilityDelegateCompat;
import androidx.core.view.ViewCompat;
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat;
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat.CollectionInfoCompat;
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat.CollectionItemInfoCompat;

import com.facebook.react.views.view.ReactViewGroup;

import java.util.ArrayList;
import java.util.List;

/**
 * Native ViewGroup that wires Android AccessibilityNodeInfo CollectionInfo /
 * CollectionItemInfo on its tab descendants — the structural data RN cannot
 * express from JS for the documented "tablist" role.
 */
public class RNAccessibleTabBarView extends ReactViewGroup {

  public RNAccessibleTabBarView(Context context) {
    super(context);
    setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_YES);
    ViewCompat.setAccessibilityDelegate(this, new AccessibilityDelegateCompat() {
      @Override
      public void onInitializeAccessibilityNodeInfo(@NonNull View host, @NonNull AccessibilityNodeInfoCompat info) {
        super.onInitializeAccessibilityNodeInfo(host, info);
        int tabCount = countAccessibleTabs(RNAccessibleTabBarView.this);
        info.setCollectionInfo(CollectionInfoCompat.obtain(
            1, // rowCount
            Math.max(tabCount, 1), // columnCount
            false, // hierarchical
            CollectionInfoCompat.SELECTION_MODE_SINGLE
        ));
      }
    });
  }

  @Override
  protected void onLayout(boolean changed, int l, int t, int r, int b) {
    super.onLayout(changed, l, t, r, b);
    applyTabDelegates();
  }

  private void applyTabDelegates() {
    List<View> tabs = new ArrayList<>();
    collectTabs(this, tabs);
    int total = tabs.size();
    for (int i = 0; i < total; i++) {
      final int index = i;
      ViewCompat.setAccessibilityDelegate(tabs.get(i), new AccessibilityDelegateCompat() {
        @Override
        public void onInitializeAccessibilityNodeInfo(@NonNull View host, @NonNull AccessibilityNodeInfoCompat info) {
          super.onInitializeAccessibilityNodeInfo(host, info);
          info.setCollectionItemInfo(CollectionItemInfoCompat.obtain(
              0, 1, // rowIndex, rowSpan
              index, 1, // columnIndex, columnSpan
              false, // heading
              info.isSelected()
          ));
        }
      });
    }
  }

  private int countAccessibleTabs(View root) {
    List<View> tabs = new ArrayList<>();
    collectTabs(root, tabs);
    return tabs.size();
  }

  private void collectTabs(View view, List<View> out) {
    if (!(view instanceof ViewGroup)) {
      return;
    }
    ViewGroup vg = (ViewGroup) view;
    for (int i = 0; i < vg.getChildCount(); i++) {
      View child = vg.getChildAt(i);
      if (isLikelyTab(child)) {
        out.add(child);
      } else if (child instanceof ViewGroup) {
        collectTabs(child, out);
      }
    }
  }

  private boolean isLikelyTab(View v) {
    if (!v.isImportantForAccessibility()) {
      return false;
    }
    CharSequence desc = v.getContentDescription();
    return v.isClickable() && desc != null && desc.length() > 0;
  }
}
