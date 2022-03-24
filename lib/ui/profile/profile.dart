import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar("Graduation Thesis"),
      backgroundColor: Colors.white70,
      body: SafeArea(child: _buildBody()),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(String text) {
    return AppBar(
      backgroundColor: Colors.amber,
      title: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[_buildMainContent()],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
              "VIETNAM NATIONAL UNIVERSITY, HO CHI MINH CITY \nUNIVERSITY OF INFORMATION TECHNOLOGY",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          _buildLogos(),
          _buildThesisPart(),
        ]),
      ),
    );
  }

  Widget _buildLogos() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Image.asset("assets/images/Logo_UIT.jpg",
                    fit: BoxFit.fitHeight)),
            Container(
                padding: EdgeInsets.only(bottom: 8),
                width: MediaQuery.of(context).size.width * 0.4,
                child: Image.asset("assets/images/Logo_SE.png",
                    fit: BoxFit.fitHeight)),
            Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Image.asset("assets/images/Logo_UIT_Together.png",
                    fit: BoxFit.fitHeight))
          ]),
    );
  }

  Widget _buildThesisPart() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      width: double.infinity,
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: Column(children: [
        Text("Graduation Thesis",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 16),
        Text("AERIAL OBJECT DETECTION",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        Divider(indent: 48, endIndent: 48, thickness: 1, color: Colors.black),
        SizedBox(height: 32),
        _buildAvatar(
            "PhD. Nguyễn Tấn Trần Minh Khang", "assets/images/GVHD.jpg", false),
        SizedBox(height: 16),
        _buildAvatar("Trần Tuấn Minh", "assets/images/TTM.jpg", true),
      ]),
    );
  }

  Widget _buildAvatar(String name, String avatar, bool isStudent) {
    return Container(
      child: Row(children: [
        Container(
          child: CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage(avatar),
              backgroundColor: Colors.transparent),
        ),
        SizedBox(width: 16),
        Flexible(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isStudent ? "Student" : "Tutor"),
            Text(name,
                maxLines: 3,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
          ]),
        )
      ]),
    );
  }
}
