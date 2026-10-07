import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_you/interface_style.dart';
import 'package:daily_you/l10n/generated/app_localizations.dart';

class PersonaDayHeader extends StatefulWidget {
  const PersonaDayHeader({super.key, required this.style});
  final InterfaceStyle style;

  @override
  State<PersonaDayHeader> createState() => _PersonaDayHeaderState();
}

class _PersonaDayHeaderState extends State<PersonaDayHeader>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startClock();
  }

  void _startClock() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (now.year != _now.year ||
          now.month != _now.month ||
          now.day != _now.day ||
          now.hour != _now.hour) {
        setState(() => _now = now);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _now = DateTime.now());
      _startClock();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isP3 = widget.style == InterfaceStyle.p3;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isP3
              ? const [Color(0xff003d77), Color(0xff0075ad)]
              : const [Color(0xff171216), Color(0xff96102c)],
        ),
        borderRadius: BorderRadius.circular(isP3 ? 24 : 4),
        border: Border(
            left: BorderSide(
                color: isP3 ? const Color(0xff7ae5ff) : const Color(0xffff3055),
                width: 6)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat.MMMd(l10n.localeName).format(_now),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.15)),
              Text(DateFormat.EEEE(l10n.localeName).format(_now),
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          Text(personaPeriod(_now, l10n),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
