import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:web/app_component.template.dart' as ng;

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(ng.AppComponentNgFactory);
}
