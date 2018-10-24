import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import '../services/database_service.dart';

@Component(
  selector: 'expose-login-button',
  templateUrl: 'login_button.html',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    './login_button.css'
  ],
  directives: const [
    MaterialButtonComponent,
  ],
)
class LoginButton {
  final DatabaseService dbService;
  LoginButton(DatabaseService this.dbService);
}
