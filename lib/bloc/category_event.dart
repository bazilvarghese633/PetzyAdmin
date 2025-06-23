abstract class CategoryEvent {}

class LoadCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String name;
  AddCategoryEvent(this.name);
}

class EditCategoryEvent extends CategoryEvent {
  final String id;
  final String newName;
  EditCategoryEvent(this.id, this.newName);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  DeleteCategoryEvent(this.id);
}

class SearchCategoryEvent extends CategoryEvent {
  final String query;
  SearchCategoryEvent(this.query);
}
