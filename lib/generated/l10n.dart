// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Back`
  String get Back {
    return Intl.message(
      'Back',
      name: 'Back',
      desc: '',
      args: [],
    );
  }

  /// `Forward`
  String get Forward {
    return Intl.message(
      'Forward',
      name: 'Forward',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get Refresh {
    return Intl.message(
      'Refresh',
      name: 'Refresh',
      desc: '',
      args: [],
    );
  }

  /// `Stealth`
  String get Stealth {
    return Intl.message(
      'Stealth',
      name: 'Stealth',
      desc: '',
      args: [],
    );
  }

  /// `Comming soon...`
  String get Comming_soon {
    return Intl.message(
      'Comming soon...',
      name: 'Comming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarks`
  String get Bookmarks {
    return Intl.message(
      'Bookmarks',
      name: 'Bookmarks',
      desc: '',
      args: [],
    );
  }

  /// `Stars`
  String get Stars {
    return Intl.message(
      'Stars',
      name: 'Stars',
      desc: '',
      args: [],
    );
  }

  /// `Historys`
  String get Historys {
    return Intl.message(
      'Historys',
      name: 'Historys',
      desc: '',
      args: [],
    );
  }

  /// `Downloads`
  String get Downloads {
    return Intl.message(
      'Downloads',
      name: 'Downloads',
      desc: '',
      args: [],
    );
  }

  /// `Keys Manager`
  String get Keys_Manager {
    return Intl.message(
      'Keys Manager',
      name: 'Keys_Manager',
      desc: '',
      args: [],
    );
  }

  /// `Desktop`
  String get Desktop {
    return Intl.message(
      'Desktop',
      name: 'Desktop',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get Edit {
    return Intl.message(
      'Edit',
      name: 'Edit',
      desc: '',
      args: [],
    );
  }

  /// `Auth Logs`
  String get Auth_Logs {
    return Intl.message(
      'Auth Logs',
      name: 'Auth_Logs',
      desc: '',
      args: [],
    );
  }

  /// `Pendding connect remote apps`
  String get Pendding_connect_remote_apps {
    return Intl.message(
      'Pendding connect remote apps',
      name: 'Pendding_connect_remote_apps',
      desc: '',
      args: [],
    );
  }

  /// `Apps Manager`
  String get Apps_Manager {
    return Intl.message(
      'Apps Manager',
      name: 'Apps_Manager',
      desc: '',
      args: [],
    );
  }

  /// `Copy success`
  String get Copy_success {
    return Intl.message(
      'Copy success',
      name: 'Copy_success',
      desc: '',
      args: [],
    );
  }

  /// `Close Edit`
  String get Close_Edit {
    return Intl.message(
      'Close Edit',
      name: 'Close_Edit',
      desc: '',
      args: [],
    );
  }

  /// `Local Relay`
  String get Local_Relay {
    return Intl.message(
      'Local Relay',
      name: 'Local_Relay',
      desc: '',
      args: [],
    );
  }

  /// `Relay`
  String get Relay {
    return Intl.message(
      'Relay',
      name: 'Relay',
      desc: '',
      args: [],
    );
  }

  /// `Secret`
  String get Secret {
    return Intl.message(
      'Secret',
      name: 'Secret',
      desc: '',
      args: [],
    );
  }

  /// `Connect by`
  String get Connect_by {
    return Intl.message(
      'Connect by',
      name: 'Connect_by',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get Confirm {
    return Intl.message(
      'Confirm',
      name: 'Confirm',
      desc: '',
      args: [],
    );
  }

  /// `Add Remote App`
  String get Add_Remote_App {
    return Intl.message(
      'Add Remote App',
      name: 'Add_Remote_App',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get Name {
    return Intl.message(
      'Name',
      name: 'Name',
      desc: '',
      args: [],
    );
  }

  /// `Pubkey`
  String get Pubkey {
    return Intl.message(
      'Pubkey',
      name: 'Pubkey',
      desc: '',
      args: [],
    );
  }

  /// `Fully trust`
  String get Fully_trust {
    return Intl.message(
      'Fully trust',
      name: 'Fully_trust',
      desc: '',
      args: [],
    );
  }

  /// `Reasonable`
  String get Reasonable {
    return Intl.message(
      'Reasonable',
      name: 'Reasonable',
      desc: '',
      args: [],
    );
  }

  /// `Alway reject`
  String get Alway_reject {
    return Intl.message(
      'Alway reject',
      name: 'Alway_reject',
      desc: '',
      args: [],
    );
  }

  /// `ConnectType`
  String get ConnectType {
    return Intl.message(
      'ConnectType',
      name: 'ConnectType',
      desc: '',
      args: [],
    );
  }

  /// `Always Allow`
  String get Always_Allow {
    return Intl.message(
      'Always Allow',
      name: 'Always_Allow',
      desc: '',
      args: [],
    );
  }

  /// `Always Reject`
  String get Always_Reject {
    return Intl.message(
      'Always Reject',
      name: 'Always_Reject',
      desc: '',
      args: [],
    );
  }

  /// `App Detail`
  String get App_Detail {
    return Intl.message(
      'App Detail',
      name: 'App_Detail',
      desc: '',
      args: [],
    );
  }

  /// `EventKind`
  String get EventKind {
    return Intl.message(
      'EventKind',
      name: 'EventKind',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get Approve {
    return Intl.message(
      'Approve',
      name: 'Approve',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get Reject {
    return Intl.message(
      'Reject',
      name: 'Reject',
      desc: '',
      args: [],
    );
  }

  /// `Click and Login`
  String get Click_and_Login {
    return Intl.message(
      'Click and Login',
      name: 'Click_and_Login',
      desc: '',
      args: [],
    );
  }

  /// `no apps now`
  String get no_apps_now {
    return Intl.message(
      'no apps now',
      name: 'no_apps_now',
      desc: '',
      args: [],
    );
  }

  /// `Show more apps`
  String get Show_more_apps {
    return Intl.message(
      'Show more apps',
      name: 'Show_more_apps',
      desc: '',
      args: [],
    );
  }

  /// `no logs now`
  String get no_logs_now {
    return Intl.message(
      'no logs now',
      name: 'no_logs_now',
      desc: '',
      args: [],
    );
  }

  /// `Show more logs`
  String get Show_more_logs {
    return Intl.message(
      'Show more logs',
      name: 'Show_more_logs',
      desc: '',
      args: [],
    );
  }

  /// `Add bookmark`
  String get Add_bookmark {
    return Intl.message(
      'Add bookmark',
      name: 'Add_bookmark',
      desc: '',
      args: [],
    );
  }

  /// `Url`
  String get Url {
    return Intl.message(
      'Url',
      name: 'Url',
      desc: '',
      args: [],
    );
  }

  /// `Add to index`
  String get Add_to_index {
    return Intl.message(
      'Add to index',
      name: 'Add_to_index',
      desc: '',
      args: [],
    );
  }

  /// `Add to quick action`
  String get Add_to_quick_action {
    return Intl.message(
      'Add to quick action',
      name: 'Add_to_quick_action',
      desc: '',
      args: [],
    );
  }

  /// `Input can't be null`
  String get Input_can_not_be_null {
    return Intl.message(
      'Input can\'t be null',
      name: 'Input_can_not_be_null',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get Login {
    return Intl.message(
      'Login',
      name: 'Login',
      desc: '',
      args: [],
    );
  }

  /// `Generate a private key`
  String get Generate_a_private_key {
    return Intl.message(
      'Generate a private key',
      name: 'Generate_a_private_key',
      desc: '',
      args: [],
    );
  }

  /// `Sign Event`
  String get Sign_Event {
    return Intl.message(
      'Sign Event',
      name: 'Sign_Event',
      desc: '',
      args: [],
    );
  }

  /// `Allow`
  String get Allow {
    return Intl.message(
      'Allow',
      name: 'Allow',
      desc: '',
      args: [],
    );
  }

  /// `to`
  String get to {
    return Intl.message(
      'to',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `Get Public Key`
  String get Get_Public_Key {
    return Intl.message(
      'Get Public Key',
      name: 'Get_Public_Key',
      desc: '',
      args: [],
    );
  }

  /// `sign`
  String get sign {
    return Intl.message(
      'sign',
      name: 'sign',
      desc: '',
      args: [],
    );
  }

  /// `a`
  String get a {
    return Intl.message(
      'a',
      name: 'a',
      desc: '',
      args: [],
    );
  }

  /// `event`
  String get event {
    return Intl.message(
      'event',
      name: 'event',
      desc: '',
      args: [],
    );
  }

  /// `Get Relays`
  String get Get_Relays {
    return Intl.message(
      'Get Relays',
      name: 'Get_Relays',
      desc: '',
      args: [],
    );
  }

  /// `Encrypt (NIP-04)`
  String get Encrypt04_name {
    return Intl.message(
      'Encrypt (NIP-04)',
      name: 'Encrypt04_name',
      desc: '',
      args: [],
    );
  }

  /// `Decrypt (NIP-04)`
  String get Decrypt04_name {
    return Intl.message(
      'Decrypt (NIP-04)',
      name: 'Decrypt04_name',
      desc: '',
      args: [],
    );
  }

  /// `Encrypt (NIP-44)`
  String get Encrypt44_name {
    return Intl.message(
      'Encrypt (NIP-44)',
      name: 'Encrypt44_name',
      desc: '',
      args: [],
    );
  }

  /// `Decrypt (NIP-44)`
  String get Decrypt44_name {
    return Intl.message(
      'Decrypt (NIP-44)',
      name: 'Decrypt44_name',
      desc: '',
      args: [],
    );
  }

  /// `Decrypt zap event`
  String get Decrypt_zap_event {
    return Intl.message(
      'Decrypt zap event',
      name: 'Decrypt_zap_event',
      desc: '',
      args: [],
    );
  }

  /// `detail`
  String get detail {
    return Intl.message(
      'detail',
      name: 'detail',
      desc: '',
      args: [],
    );
  }

  /// `Always`
  String get Always {
    return Intl.message(
      'Always',
      name: 'Always',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message(
      'Cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `I fully trust it`
  String get Full_trust_title {
    return Intl.message(
      'I fully trust it',
      name: 'Full_trust_title',
      desc: '',
      args: [],
    );
  }

  /// `Auto-sign all requests (except payments)`
  String get Full_trust_des {
    return Intl.message(
      'Auto-sign all requests (except payments)',
      name: 'Full_trust_des',
      desc: '',
      args: [],
    );
  }

  /// `Let's be reasonable`
  String get Reasonable_title {
    return Intl.message(
      'Let\'s be reasonable',
      name: 'Reasonable_title',
      desc: '',
      args: [],
    );
  }

  /// `Auto-approve most common requests`
  String get Reasonable_des {
    return Intl.message(
      'Auto-approve most common requests',
      name: 'Reasonable_des',
      desc: '',
      args: [],
    );
  }

  /// `I'm a bit paranoid`
  String get Always_reject_title {
    return Intl.message(
      'I\'m a bit paranoid',
      name: 'Always_reject_title',
      desc: '',
      args: [],
    );
  }

  /// `Do not sign anything without asking me!`
  String get Always_reject_des {
    return Intl.message(
      'Do not sign anything without asking me!',
      name: 'Always_reject_des',
      desc: '',
      args: [],
    );
  }

  /// `App Connect`
  String get App_Connect {
    return Intl.message(
      'App Connect',
      name: 'App_Connect',
      desc: '',
      args: [],
    );
  }

  /// `WEB`
  String get WEB {
    return Intl.message(
      'WEB',
      name: 'WEB',
      desc: '',
      args: [],
    );
  }

  /// `Android`
  String get Android {
    return Intl.message(
      'Android',
      name: 'Android',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get Remote {
    return Intl.message(
      'Remote',
      name: 'Remote',
      desc: '',
      args: [],
    );
  }

  /// `auto`
  String get auto {
    return Intl.message(
      'auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Follow System`
  String get Follow_System {
    return Intl.message(
      'Follow System',
      name: 'Follow_System',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get Light {
    return Intl.message(
      'Light',
      name: 'Light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get Dark {
    return Intl.message(
      'Dark',
      name: 'Dark',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get Setting {
    return Intl.message(
      'Setting',
      name: 'Setting',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get Language {
    return Intl.message(
      'Language',
      name: 'Language',
      desc: '',
      args: [],
    );
  }

  /// `ThemeStyle`
  String get ThemeStyle {
    return Intl.message(
      'ThemeStyle',
      name: 'ThemeStyle',
      desc: '',
      args: [],
    );
  }

  /// `Search Engine`
  String get Search_Engine {
    return Intl.message(
      'Search Engine',
      name: 'Search_Engine',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `About Me`
  String get About_Me {
    return Intl.message(
      'About Me',
      name: 'About_Me',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get Privacy {
    return Intl.message(
      'Privacy',
      name: 'Privacy',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
