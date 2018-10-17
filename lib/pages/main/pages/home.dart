import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainHomePageState();
  }
}

class MainHomePageState extends State<MainHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(child: Icon(Icons.menu, size: 25.0,), onTap: (){
            Scaffold.of(context).openDrawer();
          },),
          middle: Text('Home page'),
          trailing: Icon(Icons.message, size: 25.0,),
        ),
        child: Center(
          child: CupertinoButton(child: Text('Push'), onPressed: (){
            Navigator.of(context).push(CupertinoPageRoute<void>(
              title: 'Pushed',
              builder: (BuildContext context) => CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(),
                child: Center(child: Text('Hi'),),),
            ));
          }),
        )
    );
  }
}
