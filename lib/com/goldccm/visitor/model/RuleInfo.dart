class RuleInfo{

  List<int> userList;
  int companyId;
  int groupType;
  String groupName;
  String syncHolidays;
  String needPhoto;
  String noteCanUseLocalPic;
  String allowCheckInOffWorkDay;
  String allowApplyOffWorkDay;
  List<String> locInfo;
  List<String> checkInDate;
  List<int> whiteLists;
  int remind;
  List<String> speWorkDay;

  RuleInfo({this.userList, this.companyId, this.groupType, this.groupName,
      this.syncHolidays, this.needPhoto, this.noteCanUseLocalPic,
      this.allowCheckInOffWorkDay, this.allowApplyOffWorkDay, this.locInfo,
      this.checkInDate, this.whiteLists, this.remind, this.speWorkDay});

  @override
  String toString() {
    return 'RuleInfo{userList: $userList, companyId: $companyId, groupType: $groupType, groupName: $groupName, syncHolidays: $syncHolidays, needPhoto: $needPhoto, noteCanUseLocalPic: $noteCanUseLocalPic, allowCheckInOffWorkDay: $allowCheckInOffWorkDay, allowApplyOffWorkDay: $allowApplyOffWorkDay, locInfo: $locInfo, checkInDate: $checkInDate, whiteLists: $whiteLists, remind: $remind, speWorkDay: $speWorkDay}';
  }

}