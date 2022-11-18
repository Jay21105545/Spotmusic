import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BreakpointUtils {
  Breakpoints breakpoint;
  List<Breakpoints> breakpointList = [
    Breakpoints.sm,
    Breakpoints.md,
    Breakpoints.lg,
    Breakpoints.xl,
    Breakpoints.xxl
  ];
  BreakpointUtils(this.breakpoint);

  bool get isSm => breakpoint == Breakpoints.sm;
  bool get isMd => breakpoint == Breakpoints.md;
  bool get isLg => breakpoint == Breakpoints.lg;
  bool get isXl => breakpoint == Breakpoints.xl;
  bool get isXxl => breakpoint == Breakpoints.xxl;

  bool isMoreThanOrEqualTo(Breakpoints b) {
    return breakpointList
        .sublist(breakpointList.indexOf(b))
        .contains(breakpoint);
  }

  bool isLessThanOrEqualTo(Breakpoints b) {
    return breakpointList
        .sublist(0, breakpointList.indexOf(b) + 1)
        .contains(breakpoint);
  }

  bool isMoreThan(Breakpoints b) {
    return breakpointList
        .sublist(breakpointList.indexOf(b) + 1)
        .contains(breakpoint);
  }

  bool isLessThan(Breakpoints b) {
    return breakpointList
        .sublist(0, breakpointList.indexOf(b))
        .contains(breakpoint);
  }

  bool operator >(other) {
    return isMoreThan(other);
  }

  bool operator <(other) {
    return isLessThan(other);
  }

  bool operator >=(other) {
    return isMoreThanOrEqualTo(other);
  }

  bool operator <=(other) {
    return isLessThanOrEqualTo(other);
  }

  @override
  String toString() {
    return "BreakpointUtils($breakpoint)";
  }
}

enum Breakpoints { sm, md, lg, xl, xxl }

BreakpointUtils useBreakpoints() {
  final context = useContext();
  final width = MediaQuery.of(context).size.width;
  final breakpoint = useState(Breakpoints.lg);
  final utils = BreakpointUtils(breakpoint.value);

  useEffect(() {
    if (width > 1920 && breakpoint.value != Breakpoints.xxl) {
      breakpoint.value = Breakpoints.xxl;
    } else if (width > 1366 &&
        width <= 1920 &&
        breakpoint.value != Breakpoints.xl) {
      breakpoint.value = Breakpoints.xl;
    } else if (width > 800 &&
        width <= 1366 &&
        breakpoint.value != Breakpoints.lg) {
      breakpoint.value = Breakpoints.lg;
    } else if (width > 414 &&
        width <= 800 &&
        breakpoint.value != Breakpoints.md) {
      breakpoint.value = Breakpoints.md;
    } else if (width >= 250 &&
        width <= 414 &&
        breakpoint.value != Breakpoints.sm) {
      breakpoint.value = Breakpoints.sm;
    }
    return null;
  }, [width]);

  useEffect(() {
    utils.breakpoint = breakpoint.value;
    return null;
  }, [breakpoint.value]);

  return utils;
}
