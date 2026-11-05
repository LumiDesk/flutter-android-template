part of '../common_widgets.dart';

// 展示域：首字母头像、内联错误、键值行。

/// 首字母头像。没有品牌图标时用它，颜色由标题哈希决定。
class TplLetterAvatar extends StatelessWidget {
  const TplLetterAvatar({
    super.key,
    required this.seed,
    this.size = 38,
    this.radius = 12,
  });

  final String seed;
  final double size;
  final double radius;

  static const List<Color> _palette = <Color>[
    Color(0xFF2563EB),
    Color(0xFF0E8C8C),
    Color(0xFF7C3AED),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF1F9D55),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmed = seed.trim();
    final letter = trimmed.isEmpty
        ? '?'
        : trimmed.characters.first.toUpperCase();
    final color = _palette[trimmed.hashCode.abs() % _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: color,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// 表单内联错误：与所有页面共用同一套图标、字号与语义色。
class TplInlineError extends StatelessWidget {
  const TplInlineError(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = tplSemantic(context, tplDanger);
    return Row(
      children: <Widget>[
        Icon(Icons.error_outline_rounded, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// 只读键值行：设置页的「版本」、详情页的短字段用它。
class TplKeyValueRow extends StatelessWidget {
  const TplKeyValueRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
