import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import '../services/database_service.dart';

@Component(
  selector: 'expose-header',
  templateUrl: 'header.html',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    './header.css'
  ],
  directives: const [
    MaterialButtonComponent,
    NgIf
  ],
)
class Header {
  final DatabaseService dbService;
  Header(DatabaseService this.dbService);
}
