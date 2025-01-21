import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:nostr_sdk/utils/string_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/base.dart';
import '../const/theme_style.dart';
import 'data_util.dart';

class SettingProvider extends ChangeNotifier {
  static SettingProvider? _settingProvider;

  SharedPreferences? _sharedPreferences;

  SettingData? _settingData;

  static Future<SettingProvider> getInstance() async {
    if (_settingProvider == null) {
      _settingProvider = SettingProvider();
      _settingProvider!._sharedPreferences = await DataUtil.getInstance();
      await _settingProvider!._init();
    }
    return _settingProvider!;
  }

  Future<void> _init() async {
    String? settingStr = _sharedPreferences!.getString(DataKey.SETTING);
    if (StringUtil.isNotBlank(settingStr)) {
      var jsonMap = json.decode(settingStr!);
      if (jsonMap != null) {
        var setting = SettingData.fromJson(jsonMap);
        _settingData = setting;

        return;
      }
    }

    _settingData = SettingData();
  }

  Future<void> reload() async {
    await _init();
    notifyListeners();
  }

  SettingData get settingData => _settingData!;

  /// i18n
  String? get i18n => _settingData!.i18n;

  String? get i18nCC => _settingData!.i18nCC;

  /// theme style
  int get themeStyle => _settingData!.themeStyle;

  /// theme color
  int? get themeColor => _settingData!.themeColor;

  int? get mainFontColor => _settingData!.mainFontColor;

  int? get hintFontColor => _settingData!.hintFontColor;

  int? get cardColor => _settingData!.cardColor;

  String? get backgroundImage => _settingData!.backgroundImage;

  /// fontFamily
  String? get fontFamily => _settingData!.fontFamily;

  Map<String, int> _translateSourceArgsMap = {};

  bool translateSourceArgsCheck(String str) {
    return _translateSourceArgsMap[str] != null;
  }

  double get fontSize => _settingData!.fontSize ?? Base.BASE_FONT_SIZE;

  int? get tableMode => _settingData!.tableMode;

  String? get searchEngine => _settingData!.searchEngine;

  set settingData(SettingData o) {
    _settingData = o;
    saveAndNotifyListeners();
  }

  /// i18n
  set i18n(String? o) {
    _settingData!.i18n = o;
    saveAndNotifyListeners();
  }

  void setI18n(String? i18n, String? i18nCC) {
    _settingData!.i18n = i18n;
    _settingData!.i18nCC = i18nCC;
    saveAndNotifyListeners();
  }

  /// theme style
  set themeStyle(int o) {
    _settingData!.themeStyle = o;
    saveAndNotifyListeners();
  }

  /// theme color
  set themeColor(int? o) {
    _settingData!.themeColor = o;
    saveAndNotifyListeners();
  }

  set mainFontColor(int? o) {
    _settingData!.mainFontColor = o;
    saveAndNotifyListeners();
  }

  set hintFontColor(int? o) {
    _settingData!.hintFontColor = o;
    saveAndNotifyListeners();
  }

  set cardColor(int? o) {
    _settingData!.cardColor = o;
    saveAndNotifyListeners();
  }

  set backgroundImage(String? o) {
    _settingData!.backgroundImage = o;
    saveAndNotifyListeners();
  }

  /// fontFamily
  set fontFamily(String? _fontFamily) {
    _settingData!.fontFamily = _fontFamily;
    saveAndNotifyListeners();
  }

  set fontSize(double o) {
    _settingData!.fontSize = o;
    saveAndNotifyListeners();
  }

  set tableMode(int? o) {
    _settingData!.tableMode = o;
    saveAndNotifyListeners();
  }

  set searchEngine(String? o) {
    _settingData!.searchEngine = o;
    saveAndNotifyListeners();
  }

  Future<void> saveAndNotifyListeners({bool updateUI = true}) async {
    _settingData!.updatedTime = DateTime.now().millisecondsSinceEpoch;
    var m = _settingData!.toJson();
    var jsonStr = json.encode(m);
    // print(jsonStr);
    await _sharedPreferences!.setString(DataKey.SETTING, jsonStr);

    if (updateUI) {
      notifyListeners();
    }
  }
}

class SettingData {
  /// i18n
  String? i18n;

  String? i18nCC;

  /// theme style
  late int themeStyle;

  /// theme color
  int? themeColor;

  /// main font color
  int? mainFontColor;

  /// hint font color
  int? hintFontColor;

  /// card color
  int? cardColor;

  String? backgroundImage;

  /// fontFamily
  String? fontFamily;

  double? fontSize;

  int? tableMode;

  String? searchEngine;

  /// updated time
  late int updatedTime;

  SettingData({
    this.i18n,
    this.i18nCC,
    this.themeStyle = ThemeStyle.AUTO,
    this.themeColor,
    this.mainFontColor,
    this.hintFontColor,
    this.cardColor,
    this.backgroundImage,
    this.fontFamily,
    this.fontSize,
    this.tableMode,
    this.searchEngine,
    this.updatedTime = 0,
  });

  SettingData.fromJson(Map<String, dynamic> json) {
    i18n = json['i18n'];
    i18nCC = json['i18nCC'];
    if (json['themeStyle'] != null) {
      themeStyle = json['themeStyle'];
    } else {
      themeStyle = ThemeStyle.AUTO;
    }
    themeColor = json['themeColor'];
    mainFontColor = json['mainFontColor'];
    hintFontColor = json['hintFontColor'];
    cardColor = json['cardColor'];
    backgroundImage = json['backgroundImage'];
    fontSize = json['fontSize'];
    tableMode = json['tableMode'];
    searchEngine = json['searchEngine'];
    if (json['updatedTime'] != null) {
      updatedTime = json['updatedTime'];
    } else {
      updatedTime = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['i18n'] = this.i18n;
    data['i18nCC'] = this.i18nCC;
    data['themeStyle'] = this.themeStyle;
    data['themeColor'] = this.themeColor;
    data['mainFontColor'] = this.mainFontColor;
    data['hintFontColor'] = this.hintFontColor;
    data['cardColor'] = this.cardColor;
    data['backgroundImage'] = this.backgroundImage;
    data['fontFamily'] = this.fontFamily;
    data['fontSize'] = this.fontSize;
    data['tableMode'] = this.tableMode;
    data['searchEngine'] = this.searchEngine;
    data['updatedTime'] = this.updatedTime;
    return data;
  }
}
