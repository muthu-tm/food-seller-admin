enum StoreType {
  SuperMarket,
  Groceries,
  Fruits,
  Vegetables,
  HomeMadeFoods,
  Cake,
  OrganicStore,
  FishAndMeat,
  Footwear,
  Garments,
  ToyStore,
  Gardening,
  Cosmetics,
  Electronincs,
  Stationaries,
  Mobile,
  Bouquet,
  FastFood,
  ChocoAndCandy,
  Traditional,
  DryFruitsAndNuts,
  Rice,
  HomeLiving,
  Furnitures,
  Jewellery,
  Fashion,
  Pharmacy,
  Restaurant,
  Fireworks,
  Others
}

extension StoreTypeExtension on StoreType {
  int get name {
    switch (this) {
      case StoreType.SuperMarket:
        return 0;
        break;
      case StoreType.Groceries:
        return 1;
        break;
      case StoreType.Fruits:
        return 2;
        break;
      case StoreType.Vegetables:
        return 3;
        break;
      case StoreType.HomeMadeFoods:
        return 4;
        break;
      case StoreType.Cake:
        return 5;
        break;
      case StoreType.OrganicStore:
        return 6;
        break;
      case StoreType.FishAndMeat:
        return 7;
        break;
      case StoreType.Footwear:
        return 8;
        break;
      case StoreType.Garments:
        return 9;
        break;
      case StoreType.ToyStore:
        return 10;
        break;
      case StoreType.Gardening:
        return 11;
        break;
      case StoreType.Cosmetics:
        return 12;
        break;
      case StoreType.Electronincs:
        return 13;
        break;
      case StoreType.Stationaries:
        return 14;
        break;
      case StoreType.Mobile:
        return 15;
        break;
      case StoreType.Bouquet:
        return 16;
        break;
      case StoreType.FastFood:
        return 17;
        break;
      case StoreType.ChocoAndCandy:
        return 18;
        break;
      case StoreType.Traditional:
        return 19;
        break;
      case StoreType.DryFruitsAndNuts:
        return 20;
        break;
      case StoreType.Rice:
        return 21;
        break;
      case StoreType.HomeLiving:
        return 22;
        break;
      case StoreType.Furnitures:
        return 23;
        break;
      case StoreType.Jewellery:
        return 24;
        break;
      case StoreType.Fashion:
        return 25;
        break;
      case StoreType.Pharmacy:
        return 26;
        break;
      case StoreType.Restaurant:
        return 27;
        break;
      case StoreType.Fireworks:
        return 28;
        break;
      case StoreType.Others:
        return 29;
        break;
      default:
        return 29;
    }
  }
}
