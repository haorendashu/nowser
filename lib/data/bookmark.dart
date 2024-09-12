class Bookmark {
  int? id;
  String? title;
  String? url;
  String? favicon;
  int? weight;
  int? addedToIndex;
  int? createdAt;

  Bookmark(
      {this.id,
      this.title,
      this.url,
      this.favicon,
      this.weight,
      this.addedToIndex,
      this.createdAt});

  Bookmark.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    favicon = json['favicon'];
    weight = json['weight'];
    addedToIndex = json['added_to_index'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['url'] = this.url;
    data['favicon'] = this.favicon;
    data['weight'] = this.weight;
    data['added_to_index'] = this.addedToIndex;
    data['created_at'] = this.createdAt;
    return data;
  }
}
