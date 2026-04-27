class UserDto {
  String? id;
  String? authProvider;
  String? name;
  String? userType;
  String? email;
  String? phone;
  String? imageUrl;

  UserDto({
    this.id,
    this.authProvider,
    this.name,
    this.userType,
    this.email,
    this.phone,
    this.imageUrl,
  });

  UserDto.fromJson(dynamic json) {
    id = json['id'];
    authProvider = json['auth_provider'];
    name = json['name'];
    userType = json['user_type'];
    email = json['email'];
    phone = json['phone'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['auth_provider'] = authProvider;
    map['name'] = name;
    map['user_type'] = userType;
    map['email'] = email;
    map['phone'] = phone;
    map['image_url'] = imageUrl;
    return map;
  }
}
