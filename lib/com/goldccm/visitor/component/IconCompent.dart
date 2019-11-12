import 'package:flutter/material.dart';


class IconCompent extends StatefulWidget{
  final String image;
  final String text;
  final Function onTap;

  const IconCompent({
    Key key,
    this.image,
    this.text,
    this.onTap,
  }):assert(image!=null ||text!=null ||onTap!=null),
        super(key:key);


  @override
  State<StatefulWidget> createState() {
    return new IconCompentState();
  }

  }

class IconCompentState extends State<IconCompent>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Image.asset(widget.image,fit: BoxFit.cover),
          new Text(widget.text,style: new TextStyle(fontSize: 14.0,fontFamily: '楷体_GB2312'),),
          new InkWell(
            onTap: widget.onTap,
          ),
        ],

    ),
    );
  }




}

