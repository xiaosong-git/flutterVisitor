/*
 * BadgeInfo
 * newMessageCount 新消息数量
 * newFriendRequestCount 新好友申请数量
 * newNoticeCount 新公告数量
 * newVisitCount 新访问数量
 * newInviteCount 新邀约数量
 */

class BadgeInfo{

   int newMessageCount;
   int newFriendRequestCount;
   int newNoticeCount;
   int newVisitCount;
   int newInviteCount;

   BadgeInfo({this.newMessageCount,this.newFriendRequestCount,this.newNoticeCount,this.newInviteCount,this.newVisitCount});

   @override
   String toString() {
      return 'BadgeInfo{newMessageCount: $newMessageCount, newFriendRequestCount: $newFriendRequestCount, newNoticeCount: $newNoticeCount, newVisitCount: $newVisitCount, newInviteCount: $newInviteCount}';
   }

}
