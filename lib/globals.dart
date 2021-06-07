// TODO Implement this library.
library projj_app.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

List<String> device_Id = [];
List<String> paths = [];
String username;
Map<int,String> titleName = Map();
Map<int,bool> ImageList = Map();
Map<int,bool> VideoList = Map();
Map<int,bool> MusicList = Map();
Map<int,bool> fileList = Map();
Map<int,bool> AppList = Map();
List<String> Rpaths = [];
bool isSelected = false;
bool isConnected = false;
BuildContext buildContext ;
Map<String, ConnectionInfo> endpointMap = Map();
Map<int, String> map = new Map();
// ignore: non_constant_identifier_names
Map<String,String> SelectedPaths = Map();
Color themeColor;