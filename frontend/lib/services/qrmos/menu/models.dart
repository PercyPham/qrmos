class Menu {
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final List<MenuAssociation> associations;

  Menu({required this.categories, required this.items, required this.associations});

  Menu.fromJson(Map<String, dynamic> dataJson)
      : categories = _getCategoryFromJson(dataJson["categories"]),
        items = _getItemsFromJson(dataJson["items"]),
        associations = _getAssociationsFromJson(dataJson['associations']);

  static List<MenuCategory> _getCategoryFromJson(List<dynamic>? catsJson) {
    if (catsJson == null) {
      return [];
    }
    return catsJson.map((catJson) => MenuCategory.fromJson(catJson)).toList();
  }

  static List<MenuItem> _getItemsFromJson(List<dynamic>? itemsJson) {
    if (itemsJson == null) {
      return [];
    }
    return itemsJson.map((itemJson) => MenuItem.fromJson(itemJson)).toList();
  }

  static List<MenuAssociation> _getAssociationsFromJson(List<dynamic>? associationsJson) {
    if (associationsJson == null) {
      return [];
    }
    return associationsJson
        .map((associationJson) => MenuAssociation.fromJson(associationJson))
        .toList();
  }
}

class MenuAssociation {
  int itemId;
  int catId;

  MenuAssociation(this.itemId, this.catId);
  MenuAssociation.fromJson(Map<String, dynamic> dataJson)
      : itemId = dataJson["itemId"],
        catId = dataJson["catId"];
}

class MenuCategory {
  int id;
  String name;
  String description;

  MenuCategory(this.id, this.name, this.description);
  MenuCategory.fromJson(Map<String, dynamic> dataJson)
      : id = dataJson['id'],
        name = dataJson['name'],
        description = dataJson['description'] ?? "";
}

class MenuItem {
  int id;
  String name;
  String description;
  String image;
  bool available;
  int baseUnitPrice;
  Map<String, MenuItemOption> options;

  MenuItem({
    required this.id,
    required this.name,
    this.description = "",
    this.image = "",
    required this.available,
    required this.baseUnitPrice,
    this.options = const {},
  });
  MenuItem.fromJson(Map<String, dynamic> dataJson)
      : id = dataJson['id'],
        name = dataJson['name'],
        description = dataJson['description'] ?? "",
        image = dataJson['image'] ?? "",
        available = dataJson['available'] == true,
        baseUnitPrice = dataJson['baseUnitPrice'],
        options = _getOptionsFromJson(dataJson['options'] ?? {});

  static Map<String, MenuItemOption> _getOptionsFromJson(Map<String, dynamic> optionsRaw) {
    Map<String, MenuItemOption> options = {};
    optionsRaw.forEach((key, value) {
      options[key] = MenuItemOption.fromJson(value);
    });
    return options;
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "available": available,
        "baseUnitPrice": baseUnitPrice,
        "options": options,
      };

  bool get isChoosable {
    if (!available) return false;
    var notChoosableOpts = options.keys.where((optName) => !options[optName]!.isChoosable).toList();
    if (notChoosableOpts.isNotEmpty) {
      return false;
    }
    return true;
  }
}

class MenuItemOption {
  bool available;
  int maxChoice;
  int minChoice;
  Map<String, MenuItemOptionChoice> choices;

  MenuItemOption({
    this.available = false,
    this.maxChoice = 0,
    this.minChoice = 0,
    this.choices = const {},
  });
  MenuItemOption.fromJson(Map<String, dynamic> dataJson)
      : available = dataJson['available'],
        maxChoice = dataJson['maxChoice'],
        minChoice = dataJson['minChoice'],
        choices = _getChoicesFromJson(dataJson['choices']);

  static Map<String, MenuItemOptionChoice> _getChoicesFromJson(Map<String, dynamic> choicesRaw) {
    Map<String, MenuItemOptionChoice> choices = {};
    choicesRaw.forEach((key, value) {
      choices[key] = MenuItemOptionChoice.fromJson(value);
    });
    return choices;
  }

  Map toJson() => {
        "available": available,
        "minChoice": minChoice,
        "maxChoice": maxChoice,
        "choices": choices,
      };

  bool get isChoosable {
    if (!available) return false;
    var availableChoices =
        choices.keys.where((choiceName) => choices[choiceName]!.available).toList();
    if (availableChoices.length < minChoice) {
      return false;
    }
    return true;
  }
}

class MenuItemOptionChoice {
  int price;
  bool available;

  MenuItemOptionChoice({this.price = 0, this.available = false});
  MenuItemOptionChoice.fromJson(Map<String, dynamic> dataJson)
      : price = dataJson['price'],
        available = dataJson['available'];

  Map toJson() => {
        "price": price,
        "available": available,
      };
}
