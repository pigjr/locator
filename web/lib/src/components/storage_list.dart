import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import '../services/database_service.dart';
import '../models/storage.dart';

@Pipe('search', pure: true)
class SearchPipe extends PipeTransform {
  List<Storage> transform(List<Storage> value, String searchCriteria) =>
      searchCriteria != null
          ? value
              .where((storage) => storage.items.contains(searchCriteria))
              .toList()
          : value;
}

@Component(
  selector: 'expose-storage-list',
  templateUrl: 'storage_list.html',
  styleUrls: const [
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    './storage_list.css'
  ],
  directives: const [
    MaterialIconComponent,
    MaterialButtonComponent,
    MaterialChipComponent,
    MaterialChipsComponent,
    displayNameRendererDirective,
    NgFor,
    NgIf,
    NgStyle,
    formDirectives,
    materialInputDirectives,
  ],
  pipes: [SearchPipe],
)
class StorageList {
  final DatabaseService dbService;
  String searchText;
  StorageList(DatabaseService this.dbService);

  getItemChips(String items) {
    return items.split('|').map((item) => Chip(item));
  }

  deleteSearchInput() {
    searchText = '';
  }
}

class Chip implements HasUIDisplayName {
  @override
  final String uiDisplayName;
  const Chip(this.uiDisplayName);
}
