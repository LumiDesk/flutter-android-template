/// 设备偏好。
///
/// 只放「这台设备怎么显示」这类设置，不要往里塞业务数据：
/// 业务数据走各自的 repository，偏好永远可以丢弃重建。
library;

enum ThemeModePreference { system, light, dark }

/// 主题色来源：system = 跟随 Android 动态色；preset = 内置色板。
enum ThemeColorMode { system, preset }

class TplPreferences {
  const TplPreferences({
    this.themeMode = ThemeModePreference.system,
    this.colorMode = ThemeColorMode.preset,
    this.accentIndex = 0,
    this.languageCode = '',
    this.secureScreen = true,
  });

  final ThemeModePreference themeMode;
  final ThemeColorMode colorMode;

  /// 色板索引，对应 [tplAccentPresets]。
  final int accentIndex;

  /// 空串 = 跟随系统语言；否则是 zh / en。
  final String languageCode;

  /// 防止截屏和录屏（Android FLAG_SECURE）。
  final bool secureScreen;

  TplPreferences copyWith({
    ThemeModePreference? themeMode,
    ThemeColorMode? colorMode,
    int? accentIndex,
    String? languageCode,
    bool? secureScreen,
  }) {
    return TplPreferences(
      themeMode: themeMode ?? this.themeMode,
      colorMode: colorMode ?? this.colorMode,
      accentIndex: accentIndex ?? this.accentIndex,
      languageCode: languageCode ?? this.languageCode,
      secureScreen: secureScreen ?? this.secureScreen,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'themeMode': themeMode.name,
    'colorMode': colorMode.name,
    'accentIndex': accentIndex,
    'languageCode': languageCode,
    'secureScreen': secureScreen,
  };

  factory TplPreferences.fromJson(Map<String, Object?> json) {
    return TplPreferences(
      themeMode: ThemeModePreference.values.firstWhere(
        (value) => value.name == json['themeMode'],
        orElse: () => ThemeModePreference.system,
      ),
      colorMode: ThemeColorMode.values.firstWhere(
        (value) => value.name == json['colorMode'],
        orElse: () => ThemeColorMode.preset,
      ),
      accentIndex: (json['accentIndex'] as num?)?.toInt() ?? 0,
      languageCode: json['languageCode'] as String? ?? '',
      secureScreen: json['secureScreen'] as bool? ?? true,
    );
  }
}
