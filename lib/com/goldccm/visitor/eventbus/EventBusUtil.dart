import 'package:event_bus/event_bus.dart';
/*
 * 单例EventBus
 */
class  EventBusUtil{

   EventBus eventBus;
   EventBusUtil._internal(){
     eventBus=EventBus();
   }
   static EventBusUtil _instance=new EventBusUtil._internal();
   factory EventBusUtil()=>_instance;

}