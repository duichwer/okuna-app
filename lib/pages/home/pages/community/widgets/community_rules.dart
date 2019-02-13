import 'package:Openbook/models/community.dart';
import 'package:Openbook/provider.dart';
import 'package:Openbook/services/theme_value_parser.dart';
import 'package:Openbook/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBCommunityRules extends StatelessWidget {
  final Community community;

  OBCommunityRules(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: community.updateSubject,
      builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
        var community = snapshot.data;

        String communityRules = community?.rules;
        String communityColor = community?.color;

        if (communityRules == null || communityColor == null)
          return const SizedBox();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OBText(
                      'Rules',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OBText(community.rules)
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
