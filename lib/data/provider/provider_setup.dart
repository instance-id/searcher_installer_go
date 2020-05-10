// provider_setup.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];

List<SingleChildWidget > independentServices = [];

List<SingleChildWidget > dependentServices = [];

List<ChangeNotifierProvider> uiConsumableProviders = [];
