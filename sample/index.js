// Window polyfill for React Native macOS - must be FIRST
if (typeof window === 'undefined') {
  global.window = global;
  global.self = global;
}

const AppRegistry = require('react-native/Libraries/ReactNative/AppRegistry');
const App = require('./src/App').default;
const { name: appName } = require('./app.json');

AppRegistry.registerComponent(appName, () => App);
