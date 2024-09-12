class BrowserHistory {
  int? id;
  String? title;
  String? url;
  String? favicon;
  int? createdAt;

  BrowserHistory({this.id, this.title, this.url, this.favicon, this.createdAt});

  BrowserHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    favicon = json['favicon'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['url'] = this.url;
    data['favicon'] = this.favicon;
    data['created_at'] = this.createdAt;
    return data;
  }
}
