class SimpleStock{
  late final String name;

  SimpleStock(this.name);

  //생성자역활 factory
  factory SimpleStock.fromJson(dynamic json){
    return SimpleStock(json["name"]);
  }

  @override
  String toString(){
    return name;
  }
}