import 'dart:io' show Platform;

const REFRESH_TOKEN_KEY = 'refresh_token';
const BACKEND_TOKEN_KEY = 'backend_token';
const GOOGLE_ISSUER = 'https://accounts.google.com';
const GOOGLE_CLIENT_ID_IOS = '125789040129-62uibo24q827792gnd846cc1jdoo752s.apps.googleusercontent.com';
const GOOGLE_REDIRECT_URI_IOS = 'com.example.hikeappmobile:/oauthredirect';
const GOOGLE_CLIENT_ID_ANDROID = '125789040129-i90b31ck9jagtob63ts73ntpnfvh7at7.apps.googleusercontent.com';
const GOOGLE_REDIRECT_URI_ANDROID = 'com.example.hikeappmobile:/oauthredirect';

String clientID() {
  if(Platform.isAndroid) {
    return GOOGLE_CLIENT_ID_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_CLIENT_ID_IOS;
  }
  return '';
}

String redirectUrl() {
  if(Platform.isAndroid) {
    return GOOGLE_REDIRECT_URI_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_REDIRECT_URI_IOS;
  }
  return '';
}