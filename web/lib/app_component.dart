import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'src/components/header.dart';
import 'src/components/login_button.dart';
import 'src/components/storage_list.dart';
import 'src/services/database_service.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'expose-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [Header, LoginButton, StorageList, NgIf],
  providers: [DatabaseService, materialProviders]
)
class AppComponent {
  final DatabaseService dbService;
  AppComponent(DatabaseService this.dbService);
}
