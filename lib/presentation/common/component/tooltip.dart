import 'package:flutter/material.dart';

import 'message_balloon.dart';

class ToolTipWrapper extends StatefulWidget {
  /// 툴팁 표시를 위한 위젯
  ///
  /// [child] 감싸질 위젯
  ///
  /// [message]　툴팁에 표시될 메세지
  ///
  /// [tailPosition] 말풍선 꼬리 위치
  const ToolTipWrapper({
    required this.child,
    required this.message,
    this.tailPosition = TailPosition.topLeft,
    super.key,
  });

  final Widget child;
  final String message;
  final TailPosition tailPosition;

  @override
  State<ToolTipWrapper> createState() => _ToolTipWrapperState();
}

class _ToolTipWrapperState extends State<ToolTipWrapper> {
  final GlobalKey _key = GlobalKey();
  late Offset _offset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _getChildDetails();
        _showTooltip();
      },
      behavior: HitTestBehavior.opaque,
      key: _key,
      child: widget.child,
    );
  }

  // 툴팁 상자를 보여줍니다.
  void _showTooltip() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _TooltipOverlay(
          message: widget.message,
          offset: _offset,
          tailPosition: widget.tailPosition,
          closeTooltip: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // 자식 위젯의 오프셋 정보를 가져옵니다.
  void _getChildDetails() {
    final RenderBox renderBox =
        _key.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _offset = offset;
  }
}

class _TooltipOverlay extends StatefulWidget {
  // 최종적으로 보이는 툴팁위젯
  const _TooltipOverlay({
    required this.message,
    required this.offset,
    required this.closeTooltip,
    required this.tailPosition,
  });

  final String message;
  final Offset offset;
  final VoidCallback closeTooltip;
  final TailPosition tailPosition;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tooltipController;
  late final Animation<double> _tooltipAnimation;

  final _duration = const Duration(milliseconds: 150);

  @override
  void initState() {
    _initAnimation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget tooltipBox = GestureDetector(
      onTap: () {},
      child: AnimatedBuilder(
        animation: _tooltipController,
        builder: (context, child) {
          return Transform.scale(
            scale: _tooltipAnimation.value,
            child: Opacity(
              opacity: _tooltipAnimation.value,
              child: child,
            ),
          );
        },
        child: MessageBalloon(
          balloonColor: Colors.amber,
          message: widget.message,
          tailPosition: widget.tailPosition,
          onClosed: _closeTooltip,
        ),
      ),
    );

    return PopScope(
      onPopInvoked: (didPop) {
        _closeTooltip();
      },
      child: GestureDetector(
        onTap: _closeTooltip,
        child: Material(
          type: MaterialType.canvas,
          color: Colors.transparent,
          elevation: 0,
          child: Stack(
            children: [
              Positioned(
                top: _topPosition,
                left: _leftPosition,
                child: tooltipBox,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initAnimation() {
    _tooltipController = AnimationController(
        vsync: this, duration: _duration, reverseDuration: _duration);
    _tooltipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _tooltipController,
      curve: Curves.easeOut,
      reverseCurve: Curves.ease,
    ));

    _tooltipController.forward();
    _tooltipController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.closeTooltip();
      }
    });
  }

  void _closeTooltip() {
    _tooltipController.reverse();
  }

  double get _topPosition {
    switch (widget.tailPosition) {
      case TailPosition.topLeft:
      case TailPosition.topCenter:
      case TailPosition.topRight:
        return widget.offset.dy + 30;

      case TailPosition.bottomLeft:
      case TailPosition.bottomCenter:
      case TailPosition.bottomRight:
        return widget.offset.dy - 30;
    }
  }

  double get _leftPosition {
    switch (widget.tailPosition) {
      case TailPosition.topLeft:
      case TailPosition.bottomLeft:
        return widget.offset.dx + 2;

      case TailPosition.topCenter:
      case TailPosition.bottomCenter:
        return widget.offset.dx - 115;

      case TailPosition.topRight:
      case TailPosition.bottomRight:
        return widget.offset.dx - 200;
    }
  }
}
