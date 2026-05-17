module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        packageImportPath: 'import com.bitron.accessibilitytabs.RNAccessibleTabBarPackage;',
        packageInstance: 'new RNAccessibleTabBarPackage()',
      },
    },
  },
};
