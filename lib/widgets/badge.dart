import 'package:flutter/material.dart';

import 'package:badges/badges.dart';

class QBadge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  const QBadge({
    Key? key,
    required this.child,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      child: child,
      badgeContent: Text(value),
      badgeColor: color ?? Theme.of(context).colorScheme.secondary,
      position: BadgePosition.bottomStart(bottom: -5, start: -5),
    );
    // return Stack(
    //   alignment: Alignment.center,
    //   children: [
    //     child,
    //     Positioned(
    //       right: 8,
    //       top: 8,
    //       child: Container(
    //         padding: const EdgeInsets.all(2.0),
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(10.0),
    //           color: color ?? Theme.of(context).colorScheme.secondary,
    //         ),
    //         constraints: const BoxConstraints(
    //           minHeight: 16,
    //           minWidth: 16,
    //         ),
    //         child: Text(
    //           value,
    //           textAlign: TextAlign.center,
    //           style: const TextStyle(fontSize: 10),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
