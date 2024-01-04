import 'package:acl_flutter/screens/faa_form_candidate/screen/tab_widget/private_data_page.dart';
import 'package:flutter/material.dart';
import '../../../utils/acl_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Mode { create, update }

class FaaFormCandidatePage extends StatefulWidget {
  const FaaFormCandidatePage({super.key});

  @override
  State<FaaFormCandidatePage> createState() => _FaaFormCandidatePageState();
}

class _FaaFormCandidatePageState extends State<FaaFormCandidatePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchTextController = TextEditingController(text: null);
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    _searchTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Mode mode = Mode.create;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('FAA Form'),
      ),
      body: Column(
        children: [
          TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(AppLocalizations.of(context)!.privateData,
                      style: const TextStyle(color: AclColors.blueDark))),
              Tab(
                  child: Text(AppLocalizations.of(context)!.experience,
                      style: const TextStyle(color: AclColors.blueDark))),
              Stack(
                children: [
                  Tab(
                      child: Text(AppLocalizations.of(context)!.education,
                          style: const TextStyle(color: AclColors.blueDark))),
                ],
              ),
            ],
          ),
          const Divider(
            // Add a Divider under the TabBar
            height: 1,
            color: Colors.black,
          ),
          Expanded(
            child: Form(
              key: formKey,
              child: TabBarView(
                physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.normal),
                controller: _tabController,
                children: [
                  // Content for Tab 1
                  PrivateDataPage(
                    formKey: formKey,
                  ),
                  Center(
                      child: Container(
                    child: Text('On Progress'),
                  )),
                  Center(
                      child: Container(
                    child: Text('On Progress'),
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
