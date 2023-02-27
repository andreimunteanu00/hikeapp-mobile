import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/first_login.screen.dart';
import 'package:hikeappmobile/service/hike.service.dart';

import '../model/hike.model.dart';
import '../model/user.model.dart';
import '../service/auth.service.dart';
import 'account_suspended.screen.dart';
import 'home_logged.screen.dart';


class HikeDetailScreen extends StatefulWidget {

  final Hike hike;
  final HikeService hikeService = HikeService.instance;

  HikeDetailScreen({super.key, required this.hike});

  @override
  State createState() => HikeDetailScrenState();

}

class HikeDetailScrenState extends State<HikeDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return const Text('ss');
  }

}