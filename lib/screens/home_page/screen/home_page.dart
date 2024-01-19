import 'package:acl_flutter/screens/home_page/screen/list_notify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../di.dart';
import '../../../utils/acl_color.dart';
import '../bloc/home_page_bloc.dart';
import 'list_candidate_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchTextController = TextEditingController(text: null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getIt<HomePageBloc>().add(HomePageInitialEvent());
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    _searchTextController.clear();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<HomePageBloc, HomePageState>(
        listener: (context, state) {
          // TODO: implement listener}
        },
        child: BlocBuilder<HomePageBloc, HomePageState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  height: 150,
                  color: AclColors.primaryBlue,
                  child: Center(
                    child: ListTile(
                      title: Text(
                        state.loginModel?.name ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AclColors.white),
                      ),
                      subtitle: Text(
                        state.loginModel?.employeeNumber ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AclColors.white),
                      ),
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  tabs: [
                    Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1_sharp,color: AclColors.primaryBlue,),
                            Text(AppLocalizations.of(context)!.myRecruitment,
                                style: const TextStyle(color: AclColors.primaryBlue)),
                          ],
                        )),
                    Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.contact_mail,color: AclColors.primaryBlue,),
                            Text(AppLocalizations.of(context)!.beRecruitment,
                                style: const TextStyle(color: AclColors.primaryBlue)),
                          ],
                        )),
                    Stack(
                      children: [
                                Tab(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_active,color: AclColors.primaryBlue,),
                              Text(AppLocalizations.of(context)!.notification,
                                    style: const TextStyle(color: AclColors.primaryBlue)),
                            ],
                          )),
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
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.normal),
                    controller: _tabController,
                    children: [
                      // Content for Tab 1
                      ListCandidatePage(
                        isMyCandidate: true,searchTextController: _searchTextController,
                      ),
                      // Center(
                      //   child: Text('Tab 1 Content '+AppLocalizations.of(context)!.helloWorld,style: TextStyle(color: AclColors.blueDark),),
                      // ),
                      // Content for Tab 2
                      ListCandidatePage(
                        isMyCandidate: false,searchTextController: _searchTextController,
                      ),
                      // Content for Tab 3
                      const ListNotifyPage()
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Center(child: Container(child: Text(AppLocalizations.of(context)!.helloWorld),)),
    );
  }
}
