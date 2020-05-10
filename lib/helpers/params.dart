import 'dart:ui';

import 'package:flutter/material.dart';

class Value<T> {
  final String name;
  final String label;
  final T value;

  const Value({this.name, this.value, this.label});

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    Value typeOther = other;
    return typeOther.label == label && typeOther.name == name;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => hashValues(name, label);
}

List<Value<StepperType>> stepperTypeValue = [
  Value(
    name: 'vertical',
    value: StepperType.vertical,
    label: 'StepperType.vertical',
  ),
  Value(
    name: 'horizontal',
    value: StepperType.horizontal,
    label: 'StepperType.horizontal',
  ),
];

const List<Value<int>> intMini2Values = [
  const Value(
    name: '0',
    value: 0,
    label: '0',
  ),
  const Value(
    name: '1',
    value: 1,
    label: '1',
  ),
  const Value(
    name: '2',
    value: 2,
    label: '2',
  ),
  const Value(
    name: '3',
    value: 3,
    label: '3',
  ),
  const Value(
    name: '4',
    value: 4,
    label: '4',
  ),
];
