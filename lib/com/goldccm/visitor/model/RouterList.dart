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
    routerName = json ['companyName'];
    ip= json['ip'];
    routerAddress = json ['addr'];
    port = json['port'];
    imagePort= json ['nginxPort'].toString();
    province= json['province'];
    city = json['city'];
    area = json['area'];
  }

  @override
  String toString() {
    return 'RouterList{routerID: $routerID, routerName: $routerName, routerAddress: $routerAddress, province: $province, city: $city, area: $area, port: $port, imagePort: $imagePort, ip: $ip, routerServerUrl: $routerServerUrl, routerImageUrl: $routerImageUrl, routerWebSocketUrl: $routerWebSocketUrl, routerFileUrl: $routerFileUrl}';
  }

}