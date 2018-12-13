import 'package:Openbook/models/circle.dart';
import 'package:Openbook/models/follows_list.dart';
import 'package:Openbook/models/user.dart';
import 'package:Openbook/pages/home/lib/base_state.dart';
import 'package:Openbook/pages/home/pages/menu/pages/connections_circles/connections_circles.dart';
import 'package:Openbook/pages/home/pages/menu/pages/follows_list/follows_list.dart';
import 'package:Openbook/pages/home/pages/menu/pages/follows_lists/follows_lists.dart';
import 'package:Openbook/pages/home/pages/menu/widgets/curated_themes.dart';
import 'package:Openbook/pages/home/pages/menu/widgets/settings/settings.dart';
import 'package:Openbook/widgets/icon.dart';
import 'package:Openbook/widgets/nav_bar.dart';
import 'package:Openbook/pages/home/pages/profile/profile.dart';
import 'package:Openbook/provider.dart';
import 'package:Openbook/widgets/routes/slide_right_route.dart';
import 'package:Openbook/widgets/theming/primary_color_container.dart';
import 'package:Openbook/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMainMenuPage extends StatefulWidget {
  final OBMainMenuPageController controller;
  final OnWantsToCreateFollowsList onWantsToCreateFollowsList;
  final OnWantsToEditFollowsList onWantsToEditFollowsList;

  OBMainMenuPage(
      {this.controller,
      @required this.onWantsToCreateFollowsList,
      @required this.onWantsToEditFollowsList});

  @override
  State<StatefulWidget> createState() {
    return OBMainMenuPageState();
  }
}

class OBMainMenuPageState extends OBBasePageState<OBMainMenuPage> {
  OBMainMenuPageState();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller.attach(this);
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var localizationService = openbookProvider.localizationService;
    var userService = openbookProvider.userService;

    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: OBPrimaryColorContainer(
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: OBIcon(OBIcons.connections),
                  title: OBText('My connections circles'),
                  onTap: _onWantsToSeeConnectionsCircles,
                ),
                ListTile(
                  leading: OBIcon(OBIcons.lists),
                  title: OBText('My follows lists'),
                  onTap: _onWantsToSeeFollowsLists,
                ),
                ListTile(
                  leading: OBIcon(OBIcons.settings),
                  title: OBText(localizationService.trans('DRAWER.SETTINGS')),
                  onTap: _onWantsToSeeSettingsPage,
                ),
                ListTile(
                  leading: OBIcon(OBIcons.help),
                  title: OBText(localizationService.trans('DRAWER.HELP')),
                  onTap: () {
                    // Update the state of the app
                    // ...
                  },
                ),
                ListTile(
                  leading: OBIcon(OBIcons.logout),
                  title: OBText(localizationService.trans('DRAWER.LOGOUT')),
                  onTap: () {
                    userService.logout();
                  },
                )
              ],
            )),
            OBCuratedThemes()
          ],
        ),
      ),
    );
  }

  @override
  void scrollToTop() {}

  void _onWantsToSeeSettingsPage() async {
    incrementPushedRoutes();
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obMenuViewSettings'), widget: OBSettingsPage()));
    decrementPushedRoutes();
  }

  void _onWantsToSeeFollowsLists() async {
    incrementPushedRoutes();
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeFollowsLists'),
            widget: OBFollowsListsPage(
              onWantsToSeeFollowsList: _onWantsToSeeFollowsList,
              onWantsToCreateFollowsList: widget.onWantsToCreateFollowsList,
            )));
    decrementPushedRoutes();
  }

  void _onWantsToSeeConnectionsCircles() async {
    incrementPushedRoutes();
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeConnectionsCircles'),
            widget: OBConnectionsCirclesPage(
              onWantsToSeeConnectionsCircle: _onWantsToSeeConnectionsCircle,
              onWantsToCreateConnectionsCircle: null,
            )));
    decrementPushedRoutes();
  }

  void _onWantsToSeeConnectionsCircle(Circle connectionsCircle) async {
    incrementPushedRoutes();
    /*
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeConnectionsCircle'),
            widget: OBConnectionsCirclePage(connectionsCircle,
                onWantsToEditConnectionsCircle: widget.onWantsToEditConnectionsCircle,
                onWantsToSeeUserProfile: _onWantsToSeeUserProfile)));*/
    decrementPushedRoutes();
  }

  void _onWantsToSeeFollowsList(FollowsList followsList) async {
    incrementPushedRoutes();
    await Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSeeFollowsList'),
            widget: OBFollowsListPage(followsList,
                onWantsToEditFollowsList: widget.onWantsToEditFollowsList,
                onWantsToSeeUserProfile: _onWantsToSeeUserProfile)));
    decrementPushedRoutes();
  }

  void _onWantsToSeeUserProfile(User user) {
    Navigator.push(
        context,
        OBSlideRightRoute(
            key: Key('obSlideProfileViewFromFollowsLists'),
            widget: OBProfilePage(user)));
  }

  Widget _buildNavigationBar() {
    return OBNavigationBar(
      title: 'Menu',
    );
  }
}

class OBMainMenuPageController extends OBBasePageStateController {}
