class RouterList{
  String routerID;
  String routerName;
  String routerAddress;
  String province;
  String city;
  String area;
  String port;
  String imagePort;
  String ip;
  String routerServerUrl;
  String routerImageUrl;
  String routerWebSocketUrl;
  String routerFileUrl;

  RouterList({
    this.routerID,
    this.routerName,
    this.routerAddress,
    this.routerServerUrl,
    this.routerImageUrl,
    this.routerWebSocketUrl,
    this.routerFileUrl,
    this.ip,
    this.province,
    this.city,
    this.area,
    this.port,
    this.imagePort,
  });

  RouterList.fromJson(Map json){
    routerID = json ['id'].toString();
    routerName = json ['company_name'];
    ip= json['ip'];
    routerAddress = json ['addr'];
    port = json['port'];
    imagePort= json ['nginx_port'].toString();
  }
}