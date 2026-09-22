import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';

class const AboutScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hasActiveSubject = context.read<AppState>().activeSubject != null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.what_is_studyu),
      ),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(MdiIcons.food, size: 80, color: Colors.black),
                    ),
                    Expanded(
                      child: Icon(
                        MdiIcons.equal,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        MdiIcons.sleepOff,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                Text(
                  AppLocalizations.of(context)!.description_part1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.help,
                        size: 80,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                Text(
                  AppLocalizations.of(context)!.description_part2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.accountQuestion,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part3,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.exclamationThick,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part4,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.alphaNBoxOutline,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'of',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        MdiIcons.numeric1BoxOutline,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part5,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.notebookOutline,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part6,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.alignVerticalBottom,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part7,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                const Row(
                  children: [
                    Expanded(
                      child: Icon(
                        MdiIcons.progressCheck,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part8,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 18),
                ),
                const Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Image(
                  image: AssetImage('assets/icon/logo.png'),
                  height: 200,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.description_part9,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(MdiIcons.playCircleOutline),
                      onPressed: () => context.go('/${RouteNames.onboarding}'),
                      label: Text(
                        AppLocalizations.of(context)!.show_onboarding_again,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!hasActiveSubject)
                      OutlinedButton.icon(
                        icon: const Icon(MdiIcons.rocket),
                        onPressed: () =>
                            context.go('/${RouteNames.studySelection}'),
                        label: Text(
                          AppLocalizations.of(context)!.get_started,
                          style: const TextStyle(fontSize: 20),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(MdiIcons.rocket),
                        onPressed: () => context.go('/${RouteNames.dashboard}'),
                        label: Text(
                          AppLocalizations.of(context)!.get_started,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
