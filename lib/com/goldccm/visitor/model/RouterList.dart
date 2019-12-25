class RouterList{
  String routerID;
  String routerName;
  String routerAddress;
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
  });

  RouterList.fromJson(Map json){
    routerID = json ['imageFileName'];
    routerName = json ['name'];
    routerAddress = json ['idNo'];
    routerServerUrl = json ['address'];
    routerImageUrl = json ['bankCardNo'];
    routerWebSocketUrl= json ['bank'];
    routerFileUrl = json ['path'];
  }

}