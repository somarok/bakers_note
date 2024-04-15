import 'package:flutter/material.dart';

class MessageBalloon extends StatelessWidget {
  /// 말풍선 디자인이 들어갈 위젯입니다.
  ///
  /// [balloonColor] 툴팁 색깔을 설정합니다.
  ///
  /// [message] 툴팁 내 들어갈 문자열입니다.
  ///
  /// [tailPosition] 말풍선 꼬리 위치를 지정해줍니다. [TailPosition] enum값으로 설정할 수 있습니다.
  ///
  /// [onClosed] UI상 닫기버튼이 필요한 경우, onClosed에 호출될 메소드를 작성해줍니다. 닫기 아이콘은 자동으로 생성됩니다.
  ///
  /// [textStyle] 메세지 텍스트 스타일이 필요한 경우, 따로 설정해줍니다.
  ///
  /// [child] 말풍선 안에 텍스트 대신 넣고싶은 위젯이 있을때 사용됩니다.
  ///
  /// [maxWidth] 말풍선의 최대길이를 설정할 때 사용됩니다.
  const MessageBalloon({
    required this.balloonColor,
    this.tailPosition = TailPosition.topLeft,
    this.message,
    this.onClosed,
    this.textStyle,
    this.child,
    this.maxWidth,
    super.key,
  });

  final Color balloonColor;
  final String? message;
  final TailPosition tailPosition;
  final VoidCallback? onClosed;
  final TextStyle? textStyle;
  final Widget? child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    // 말풍선 꼬리를 그려줄 위젯. TailPosition값에 따라 Rotate가 변경되고, 꼬리가 위치할 offset이 바뀝니다.
    final Widget tailWidget = Transform.translate(
      offset: _offset,
      child: RotatedBox(
        quarterTurns: _isTopPosition ? 4 : 2,
        child: ClipPath(
          clipper: const _MessageClip(),
          child: Container(
            color: balloonColor,
            height: 5,
            width: 10,
          ),
        ),
      ),
    );

    // 말풍선을 그려줄 위젯. 안에 메세지가 들어갑니다.
    final Widget balloonWidget = Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 263,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 247, 227),
        border: Border.all(color: balloonColor),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메세지
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth ?? 220),
            child: child ??
                Text(
                  message ?? '',
                  style: textStyle ??
                      const TextStyle(color: Colors.grey, height: 1.3),
                ),
          ),

          // onClosed가 함수일 경우에 닫기 버튼을 그려줍니다.
          if (onClosed is Function)
            // 닫기버튼
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onClosed,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // 말꼬리, 말풍선을 담은 배열입니다. reverse 처리를 하기 위해 배열에 넣어둡니다.
    final List<Widget> children = [tailWidget, balloonWidget];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: _crossAxisAlignment,
      children: _isTopPosition ? children : children.reversed.toList(),
    );
  }

  /// 말풍선 포지션에 따라서 [Offset]을 반환합니다.
  Offset get _offset {
    switch (tailPosition) {
      case TailPosition.topLeft:
        return const Offset(10, 1);
      case TailPosition.topCenter:
        return const Offset(0, 1);
      case TailPosition.topRight:
        return const Offset(-10, 1);
      case TailPosition.bottomLeft:
        return const Offset(10, -1);
      case TailPosition.bottomCenter:
        return const Offset(0, -1);
      case TailPosition.bottomRight:
        return const Offset(-10, -1);
    }
  }

  /// 말풍선 포지션에 따라서 [CrossAxisAlignment]를 반환합니다.
  CrossAxisAlignment get _crossAxisAlignment {
    if (tailPosition.name.contains('Left')) {
      return CrossAxisAlignment.start;
    }
    if (tailPosition.name.contains('Center')) {
      return CrossAxisAlignment.center;
    }
    return CrossAxisAlignment.end;
  }

  /// 꼬리가 윗쪽 포지션인지 [bool]타입을 반환합니다.
  bool get _isTopPosition {
    if (tailPosition.name.contains('top')) {
      return true;
    }

    return false;
  }
}

enum TailPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

class _MessageClip extends CustomClipper<Path> {
  const _MessageClip();

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
