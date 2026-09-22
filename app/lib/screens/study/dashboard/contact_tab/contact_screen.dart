import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

class const ContactScreen({super.key}) extends StatefulWidget {
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState() extends State<ContactScreen> {
  Contact? studyContact;

  @override
  void initState() {
    super.initState();
    studyContact = context.read<AppState>().activeSubject?.study.contact;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.contact)),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: const Image(
              image: AssetImage('assets/icon/logo.png'),
              height: 80,
            ),
          ),
          RetryFutureBuilder<Contact>(
            tryFunction: AppConfig.getAppContact,
            successBuilder:
                (BuildContext context, Contact? appSupportContact) =>
                    ContactWidget(
                      contact: appSupportContact,
                      title: AppLocalizations.of(context)!.app_support,
                      subtitle: AppLocalizations.of(context)!.app_support_text,
                      color: theme.primaryColor,
                    ),
          ),
          const SizedBox(height: 20),
          ContactWidget(
            contact: studyContact,
            title: AppLocalizations.of(context)!.study_support,
            subtitle: AppLocalizations.of(context)!.study_support_text,
            color: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class const ContactWidget({
  required final Contact? contact,
  required final String title,
  required final Color color,
  final String? subtitle,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (contact == null) {
      return Container();
    }

    final titles = [
      Text(title, style: theme.textTheme.titleLarge!.copyWith(color: color)),
    ];
    if (subtitle != null && subtitle!.isNotEmpty) {
      titles.add(
        Text(
          subtitle!,
          style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        Column(mainAxisSize: MainAxisSize.min, children: titles),
        ContactItem(
          itemName: AppLocalizations.of(context)!.organization,
          itemValue: contact?.organization,
          iconData: MdiIcons.hospitalBuilding,
          iconColor: color,
        ),
        if (contact?.institutionalReviewBoard != null)
          ContactItem(
            itemName: AppLocalizations.of(context)!.irb,
            itemValue:
                contact!.institutionalReviewBoard! +
                (contact?.institutionalReviewBoardNumber != null
                    ? ': ${contact?.institutionalReviewBoardNumber}'
                    : ''),
            iconData: MdiIcons.clipboardCheck,
            iconColor: color,
          ),
        ContactItem(
          itemName: AppLocalizations.of(context)!.researchers,
          itemValue: contact?.researchers,
          iconData: MdiIcons.doctor,
          iconColor: color,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context)!.website,
          itemValue: contact?.website,
          iconData: MdiIcons.web,
          type: ContactItemType.website,
          iconColor: color,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context)!.email,
          itemValue: contact?.email,
          iconData: MdiIcons.email,
          type: ContactItemType.email,
          iconColor: color,
        ),
        ContactItem(
          itemName: AppLocalizations.of(context)!.phone,
          itemValue: contact?.phone,
          iconData: MdiIcons.phone,
          type: ContactItemType.phone,
          iconColor: color,
        ),
        if (contact?.additionalInfo != null)
          ContactItem(
            itemName: AppLocalizations.of(context)!.additionalInfo,
            itemValue: contact!.additionalInfo,
            iconData: MdiIcons.information,
            iconColor: color,
          ),
      ],
    );
  }
}

enum ContactItemType() {
  website,
  email,
  phone,
}

class const ContactItem({
  required final String itemName,
  required final String? itemValue,
  required final IconData iconData,
  final ContactItemType? type,
  final Color? iconColor,
  super.key,
}) extends StatelessWidget {
  Future<void> launchContact() async {
    {
      Uri uri;
      switch (type) {
        case ContactItemType.website:
          if (!itemValue!.startsWith('http://') &&
              !itemValue!.startsWith('https://')) {
            uri = Uri.parse('http://$itemValue');
          } else {
            uri = Uri.parse(itemValue!);
          }
        case ContactItemType.email:
          uri = Uri.parse('mailto:$itemValue');
        case ContactItemType.phone:
          uri = Uri.parse('tel:$itemValue');
        default:
          uri = Uri.parse(itemValue!);
      }
      if (await canLaunchUrl(uri)) {
        launchUrl(uri);
      } else {
        StudyULogger.warning("Cannot launch Url: $uri");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemValue == null || itemValue!.isEmpty) return Container();

    const iconSize = 40.0;
    return ListTile(
      title: Text(itemName),
      subtitle: SelectableText(itemValue!),
      leading: Icon(
        iconData,
        color: iconColor ?? Theme.of(context).primaryColor,
        size: iconSize,
      ),
      onTap: type != null ? launchContact : null,
    );
  }
}
