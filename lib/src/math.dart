import 'dart:math' as math;

const epsilon = 1e-6;
const epsilon2 = 1e-12;
const pi = math.pi;
const halfPi = pi / 2;
const quarterPi = pi / 4;
const tau = pi * 2;

const degrees = 180 / pi;
const radians = pi / 180;

const atan = math.atan;
const atan2 = math.atan2;
const cos = math.cos;
const exp = math.exp;
const log = math.log;
const pow = math.pow;
const sin = math.sin;
const sqrt = math.sqrt;
const tan = math.tan;

const min = math.min;

num abs(num x) => x.abs();

num sign(num x) => x.sign;

double hypot(List<double> x) {
  var sum = 0.0, i = 0, aLen = x.length;
  num larg = 0, arg, div;
  while (i < aLen) {
    arg = abs(x[i++]);
    if (larg < arg) {
      div = larg / arg;
      sum = sum * div * div + 1;
      larg = arg;
    } else if (arg > 0) {
      div = arg / larg;
      sum += div * div;
    } else {
      sum += arg;
    }
  }
  return larg == double.infinity ? double.infinity : larg * sqrt(sum);
}

int round(double x) => x.round();

double acos(num x) => x > 1
    ? 0
    : x < -1
        ? pi
        : math.acos(x);

double asin(double x) => x > 1
    ? halfPi
    : x < -1
        ? -halfPi
        : math.asin(x);

double haversin(double x) => (x = sin(x / 2)) * x;
