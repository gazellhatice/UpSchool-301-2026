import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _collapsedKey = 'landing_team_announcement_collapsed';
const _topKey = 'landing_team_announcement_top';
const _announcementRed = Color(0xFFC62828);
const _announcementRedDark = Color(0xFFB71C1C);

const _expandedHeightEstimate = 132.0;
const _collapsedHeightEstimate = 46.0;

/// Tanıtım sayfalarında (/, /hakkimizda, /indir, /iletisim) gösterilen ekip duyurusu.
class LandingTeamAnnouncement extends StatefulWidget {
  const LandingTeamAnnouncement({super.key});

  @override
  State<LandingTeamAnnouncement> createState() =>
      _LandingTeamAnnouncementState();
}

class _LandingTeamAnnouncementState extends State<LandingTeamAnnouncement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slide;

  bool _ready = false;
  bool _expanded = true;
  double? _topOffset;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slide = Tween<Offset>(
      begin: const Offset(-1.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final collapsed = prefs.getBool(_collapsedKey) ?? false;
    final savedTop = prefs.getDouble(_topKey);
    if (!mounted) return;
    setState(() {
      _ready = true;
      _expanded = !collapsed;
      _topOffset = savedTop;
    });
    if (!collapsed) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted || !_expanded) return;
      await _slideController.forward();
    } else {
      _slideController.value = 1;
    }
  }

  void _clampTop(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height =
        _expanded ? _expandedHeightEstimate : _collapsedHeightEstimate;
    final minTop = mq.padding.top + 64;
    final maxTop = (mq.size.height - height - mq.padding.bottom - 72)
        .clamp(minTop, double.infinity);
    final current = _topOffset ?? mq.padding.top + 88;
    _topOffset = current.clamp(minTop, maxTop);
  }

  Future<void> _saveTopOffset() async {
    if (_topOffset == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_topKey, _topOffset!);
  }

  void _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    setState(() {
      _dragging = true;
      _topOffset = _resolvedTop(context) + details.delta.dy;
      _clampTop(context);
    });
  }

  double _resolvedTop(BuildContext context) {
    return _topOffset ?? MediaQuery.paddingOf(context).top + 88;
  }

  void _onVerticalDragEnd() {
    setState(() => _dragging = false);
    _saveTopOffset();
  }

  Future<void> _collapse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_collapsedKey, true);
    if (!mounted) return;
    setState(() {
      _expanded = false;
      _clampTop(context);
    });
    _saveTopOffset();
  }

  Future<void> _expand() async {
    setState(() => _expanded = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_collapsedKey, false);
    _clampTop(context);
    await _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox.shrink();
    }

    final mq = MediaQuery.of(context);
    final height =
        _expanded ? _expandedHeightEstimate : _collapsedHeightEstimate;
    final minTop = mq.padding.top + 64;
    final maxTop = (mq.size.height - height - mq.padding.bottom - 72)
        .clamp(minTop, double.infinity);
    final top = (_topOffset ?? mq.padding.top + 88).clamp(minTop, maxTop);

    return Positioned(
      left: 0,
      top: top,
      child: MouseRegion(
        cursor: _dragging
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab,
        child: GestureDetector(
          onVerticalDragStart: (_) => setState(() => _dragging = true),
          onVerticalDragUpdate: (d) => _onVerticalDragUpdate(context, d),
          onVerticalDragEnd: (_) => _onVerticalDragEnd(),
          child: SlideTransition(
            position: _slide,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    axis: Axis.horizontal,
                    axisAlignment: -1,
                    sizeFactor: animation,
                    child: child,
                  ),
                );
              },
              child: _expanded
                  ? _ExpandedPanel(
                      key: const ValueKey('expanded'),
                      onCollapse: _collapse,
                    )
                  : _CollapsedBadge(
                      key: const ValueKey('collapsed'),
                      onTap: _expand,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHint extends StatelessWidget {
  const _DragHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            color: Colors.white.withValues(alpha: 0.85),
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            'Yukarı-aşağı sürükle',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel({super.key, required this.onCollapse});

  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: (MediaQuery.sizeOf(context).width - 24).clamp(0, 340),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 14),
        decoration: const BoxDecoration(
          color: _announcementRed,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border(
            right: BorderSide(color: _announcementRedDark, width: 1),
            top: BorderSide(color: _announcementRedDark, width: 1),
            bottom: BorderSide(color: _announcementRedDark, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DragHint(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ekibe mesaj!',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Proje ana taslakta mobil olarak tasarlanmıştı. '
                        'App Store ve Play Store ücretleri nedeniyle ek olarak '
                        'web sürümü de geliştirilip eklenmiştir.',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCollapse,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Küçült',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedBadge extends StatelessWidget {
  const _CollapsedBadge({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(14),
        bottomRight: Radius.circular(14),
      ),
      child: Tooltip(
        message: 'Ekibe mesajını oku · sürükleyerek taşı',
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          child: Ink(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: _announcementRed,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border(
                right: BorderSide(color: _announcementRedDark),
                top: BorderSide(color: _announcementRedDark),
                bottom: BorderSide(color: _announcementRedDark),
              ),
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
