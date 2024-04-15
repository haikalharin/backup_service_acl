import 'package:acl_flutter/data/model/candidate/candidate_data_model.dart';
import 'package:acl_flutter/data/model/candidate/candidate_model.dart';
import 'package:acl_flutter/screens/faa_form_candidate/screen/tab_widget/education_data_page.dart';
import 'package:acl_flutter/screens/faa_form_candidate/screen/tab_widget/private_data_page.dart';
import 'package:acl_flutter/screens/faa_form_candidate/screen/tab_widget/work_experience_data_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../core/dialog/progress_dialog.dart';
import '../../../core/dialog/retry_dialog.dart';
import '../../../core/dialog/success_dialog.dart';
import '../../../common/widget/spinkit_indicator.dart';
import '../../../di.dart';
import '../../../utils/acl_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/faa_candidate_page_bloc.dart';

enum Mode { create, update }

bool isSuccesPrivateTab = true;
bool isSuccesWorkExperienceTab = true;
bool isSuccesEducationTab = false;

class FaaFormCandidatePage extends StatefulWidget {
  CandidateModel? candidateModel = CandidateModel();

  FaaFormCandidatePage({super.key,  this.candidateModel});

  @override
  State<FaaFormCandidatePage> createState() => _FaaFormCandidatePageState();
}

class _FaaFormCandidatePageState extends State<FaaFormCandidatePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchTextController = TextEditingController(text: null);
  final formKey = GlobalKey<FormState>();

  int _tabindex = 0;

  @override
  void initState() {
    super.initState();
    isSuccesPrivateTab = true;
    isSuccesWorkExperienceTab = false;
    isSuccesEducationTab = false;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    isSuccesPrivateTab = true;
    isSuccesWorkExperienceTab = false;
    isSuccesEducationTab = false;
    super.dispose();
  }

  void _handleTabChange() {
    _searchTextController.clear();
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          getIt<FaaCandidatePageBloc>().add(TabTypeInputEvent(TabType.private));
          // showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return const SuccessDialog(
          //       title: "1",
          //       isProgressed: false,
          //     );
          //   },
          // );
          break;
        case 1:
          getIt<FaaCandidatePageBloc>()
              .add(TabTypeInputEvent(TabType.experience));
          if (isSuccesPrivateTab) {
            _tabController.index = 1;
          } else {
            _tabController.index = 0;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return RetryDialog(
                  title: "Mohon selesaikan halaman ini terlebih dahulu",
                  onCancelPressed: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
          break;
        case 2:
          getIt<FaaCandidatePageBloc>()
              .add(TabTypeInputEvent(TabType.education));
          if (isSuccesWorkExperienceTab) {
            _tabController.index = 2;
          } else {
            _tabController.index = 1;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return RetryDialog(
                  title: "Mohon selesaikan halaman ini terlebih dahulu",
                  onCancelPressed: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Mode mode = Mode.create;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Form Aplikasi Agent',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: BlocListener<FaaCandidatePageBloc, FaaCandidatePageState>(
        listener: (context, state) {
          if (state.submitStatus.isSuccess) {
            if (state.message == 'success-get-master-data') {}
            if (state.message == 'success-add-private-data') {
              isSuccesPrivateTab = true;
              _tabController.index = 1;
            }
            if (state.message == 'success-submit-work-experience') {
              isSuccesWorkExperienceTab =true;
              _tabController.index = 2;
            }
            if (state.message == 'success-submit-work-experience') {
              isSuccesEducationTab = true;
            }
          }
        },
        child: BlocBuilder<FaaCandidatePageBloc, FaaCandidatePageState>(
          builder: (context, state) {
            // if (state.firstName.isValid) {
            //   isSuccesPrivateTab = true;
            // }
            return Column(
              children: [
                TabBar(
                  physics: const NeverScrollableScrollPhysics(),
                  isScrollable: true,
                  controller: _tabController,
                  tabs: [
                    Tab(
                        child: Text(AppLocalizations.of(context)!.privateData,
                            style:
                                const TextStyle(color: AclColors.primaryBlue))),
                    Tab(
                        child: Text(AppLocalizations.of(context)!.experience,
                            style:
                                const TextStyle(color: AclColors.primaryBlue))),
                    Tab(
                        child: Text(AppLocalizations.of(context)!.education,
                            style:
                                const TextStyle(color: AclColors.primaryBlue))),
                  ],
                ),
                const Divider(
                  // Add a Divider under the TabBar
                  height: 1,
                  color: Colors.black,
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      // Content for Tab 1
                      PrivateDataPage(
                        tabController: _tabController,
                      ),
                      WorkExperienceDataPage(
                        tabController: _tabController,
                      ),
                      EducationDataPage(
                        tabController: _tabController,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
