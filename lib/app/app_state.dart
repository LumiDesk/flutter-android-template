import 'models/item.dart';

/// 启动阶段：loading 时显示启动页，ready 后进入主界面。
enum TplStatus { loading, ready }

/// 可翻译的错误码。
///
/// 界面只拿枚举，文案由 messages.dart 查 ARB；不要把技术异常字符串直接显示给用户。
enum TplError { storageRead, storageWrite, titleRequired }

/// 一次性提示码（成功类），由反馈宿主消费后清空。
enum TplNotice { saved, deleted }

class TplState {
  const TplState({
    this.status = TplStatus.loading,
    this.items = const <Item>[],
    this.error,
    this.notice,
  });

  final TplStatus status;
  final List<Item> items;
  final TplError? error;
  final TplNotice? notice;

  TplState copyWith({
    TplStatus? status,
    List<Item>? items,
    TplError? error,
    TplNotice? notice,
    bool clearError = false,
    bool clearNotice = false,
  }) {
    return TplState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}
