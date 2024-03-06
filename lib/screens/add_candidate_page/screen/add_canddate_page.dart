import 'package:acl_flutter/common/app_extension.dart';
import 'package:acl_flutter/common/widget/dropdown/drop_down_general.dart';
import 'package:acl_flutter/common/widget/dropdown/drop_down_general_second.dart';
import 'package:acl_flutter/core/dialog/success_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_helper/source/components/buttons/adaptive_button.dart';
import 'package:formz/formz.dart';

import '../../../common/widget/dropdown/drop_down_general_third.dart';
import '../../../core/dialog/progress_dialog.dart';
import '../../../core/dialog/retry_dialog.dart';
import '../../../core/router/routes.dart';
import '../../../common/widget/custom_image_picker.dart';
import '../../../common/widget/date_time_picker_form.dart';
import '../../../common/widget/spinkit_indicator.dart';
import '../../../common/widget/text_input.dart';
import '../../../data/model/login_model/login_model.dart';
import '../../../data/model/master_data_model/master_data_model.dart';
import '../../../di.dart';
import '../../../utils/acl_color.dart';
import '../bloc/add_candidate_page_bloc.dart';

enum Mode { create, update }

class AddCandidatePage extends StatefulWidget {
  const AddCandidatePage({Key? key}) : super(key: key);

  @override
  State<AddCandidatePage> createState() => _AddCandidatePageState();
}

class _AddCandidatePageState extends State<AddCandidatePage> {
  final formKey = GlobalKey<FormState>();
  var aauiController = TextEditingController(text: "");
  var noIdentitySpouse = TextEditingController(text: "");
  var firstNameSpouse = TextEditingController(text: "");
  var middleNameSpouse = TextEditingController(text: "");
  var lastNameSpouse = TextEditingController(text: "");
  var dobSpouse = TextEditingController(text: "");
  AajicityMasterReference? initialGenderSpouse = AajicityMasterReference();
  AajicityMasterReference? initialRelationSpouse = AajicityMasterReference();

  LoginModel? selectedItem;
  bool checkedPrevCompanyAAJI = false;
  bool checkedPrevCompanyAASI = false;
  bool checkedValueAAUI = false;
  bool checkedPrevCompanyAAUI = false;
  bool checkedValueMarriage = true;
  bool isCheck = false;
  bool isInitGender = false;
  bool isInitRelation = false;
  var data = [
    LoginModel(name: 'adadada', uid: '1'),
    LoginModel(name: 'bccccc', uid: '2'),
    LoginModel(name: 'cfffffff', uid: '3'),
    LoginModel(name: 'dggggg', uid: '4'),
    LoginModel(name: 'errrrr', uid: '5'),
    LoginModel(name: 'fuuuuu', uid: '6'),
  ];

  @override
  void initState() {
    getIt<AddCandidatePageBloc>().add(FetchMasterDataEvent());
    super.initState();
  }

  @override
  void dispose() {
    getIt<AddCandidatePageBloc>().add(AddCandidatePageInitialEvent());
    super.dispose();
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
          'Permintaan Pemeriksaan',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: BlocListener<AddCandidatePageBloc, AddCandidatePageState>(
        listener: (context, state) async {
          if (state.submitStatus.isSuccess &&
              state.message == 'create-register') {
            getIt<AddCandidatePageBloc>().add(AddAgentDocSubmittedEvent());
          }
          if (state.submitStatus.isSuccess && state.message == 'send-doc') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const SuccessDialog(
                  title: "Success",
                  isProgressed: false,
                );
              },
            );
            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.sidebarPage,
                (Route<dynamic> route) => false,
              );
            }
          }
          if (state.submitStatus.isFailure) {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RetryDialog(
                    title: state.message ?? "Error",
                    onCancelPressed: () => Navigator.pop(context),
                  );
                },
              );
            }
          }
        },
        child: BlocBuilder<AddCandidatePageBloc, AddCandidatePageState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          TextInput(
                            icon: const Icon(Icons.person),
                            labelText: "Nama Depan(sesuai KTP)",
                            // initialValue: postTitle,
                            validator: (String? value) {
                              if (value!.isNotEmpty) return null;
                              return "Mohon diisi";
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(FirstNameInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            isMandatory: false,
                            icon: const Icon(Icons.person),
                            labelText: "Nama tengah(sesuai KTP)",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(MiddleNameInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            isMandatory: false,
                            icon: const Icon(Icons.person),
                            labelText: "Nama belakang(sesuai KTP)",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(LastNameInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          DateTimePickerForm(
                            labelText: "Pilih Tanggal",
                            title: "Tanggal lahir",
                            errorText: isCheck == true && state.dob.isNotValid
                                ? 'Mohon diisi'
                                : null,
                            selectedDateTime: (DateTime date) {
                              var month = date.month.toString().length == 1
                                  ? '0${date.month}'
                                  : date.month;
                              var day = date.day.toString().length == 1
                                  ? '0${date.day}'
                                  : date.day;
                              var dateTime = "${date.year}-$month-$day";
                              getIt<AddCandidatePageBloc>()
                                  .add(DobInputEvent(dateTime));
                            },
                            validator: (String? value) {
                              if (value!.isNotEmpty) return null;
                              return "Mohon diisi";
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            icon: const Icon(Icons.add_card_rounded),
                            labelText: "No KTP",
                            maxLength: 16,
                            keyboardType: TextInputType.phone,
                            validator: (String? value) {
                              if (state.identityNo.isNotValid) {
                                return state.identityNo.invalidIdentityNo;
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(IdentityNoInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          CustomImagePicker(
                            title: 'Foto KTP',
                            onImagePicked: (value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(IdentityImageInputEvent(value));
                            },
                            errorText: isCheck && state.identityImage.isNotValid
                                ? 'Mohon diisi'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          CustomImagePicker(
                            title: 'Foto Selfie Beserta KTP',
                            onImagePicked: (value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(IdentitySelfieImageInputEvent(value));
                            },
                            errorText:
                                isCheck && state.identitySelfieImage.isNotValid
                                    ? 'Mohon diisi'
                                    : null,
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            icon: const Icon(Icons.add_card_rounded),
                            labelText: "No KK",
                            maxLength: 16,
                            keyboardType: TextInputType.phone,
                            validator: (String? value) {
                              if (state.kkNo.isNotValid) {
                                return "KK harus 16 digit";
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(KkNoInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          CustomImagePicker(
                            title: 'Foto KK',
                            onImagePicked: (value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(KkImageInputEvent(value));
                            },
                            errorText: isCheck && state.kkImage.isNotValid
                                ? 'Mohon diisi'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            title: Row(
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: const Text(
                                        'Alamat rumah (sesuai KTP)',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: AclColors.greyDarkFontColor,
                                        ))),
                                Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, bottom: 5),
                                    child: const Text(
                                      '*',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: AclColors.red,
                                      ),
                                    ))
                              ],
                            ),
                            icon: const Icon(Icons.add_location),
                            labelText: "(Gedung.../Jalan...)",
                            validator: (String? value) {
                              if (value!.isNotEmpty) return null;
                              return "Mohon diisi";
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(AddressInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            icon: const Icon(Icons.add_location),
                            isMandatory: false,
                            labelText: "(RT.../RW...)",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(RtRwInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            icon: const Icon(Icons.add_location),
                            isMandatory: false,
                            labelText: "(Kelurahan.../Kecamatan...)",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(KecKelInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            icon: const Icon(Icons.signpost_sharp),
                            labelText: "Kode Pos",
                            keyboardType: TextInputType.phone,
                            maxLength: 5,
                            validator: (String? value) {
                              if (state.postalCode.isNotValid) {
                                return state.postalCode.invalidZipcode;
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(PostalCodeInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<AddCandidatePageBloc,
                              AddCandidatePageState>(
                            builder: (context, state) {
                              return DropDownGeneral(
                                title: 'Negara',
                                icon: const Icon(
                                  Icons.account_balance_rounded,
                                  color: AclColors.greyDarkFontColor,
                                ),
                                onChanged: (value) {
                                  getIt<AddCandidatePageBloc>()
                                      .add(CountryInputEvent(value));
                                },
                                readOnly: true,
                                initialItem: state
                                    .masterDataModel
                                    ?.masterData
                                    ?.masterReferenceAll
                                    ?.country
                                    ?.masterReference
                                    ?.where((element) => element.id == 744)
                                    .toList()
                                    .first,
                                items: state
                                        .masterDataModel
                                        ?.masterData
                                        ?.masterReferenceAll
                                        ?.country
                                        ?.masterReference
                                        ?.where((element) => element.id == 744)
                                        .toList() ??
                                    [],
                                errorText: isCheck == true &&
                                        state.countryId.isNotValid
                                    ? 'Mohon diisi'
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<AddCandidatePageBloc,
                              AddCandidatePageState>(
                            buildWhen: (current, previous) =>
                                current.provinceId != previous.provinceId ||
                                current.masterDataModel !=
                                    previous.masterDataModel,
                            builder: (context, state) {
                              return DropDownGeneral(
                                title: 'Provinsi',
                                icon: const Icon(
                                  Icons.account_balance_rounded,
                                  color: AclColors.greyDarkFontColor,
                                ),
                                onChanged: (AajicityMasterReference value) {
                                  getIt<AddCandidatePageBloc>()
                                      .add(ProvinceInputEvent(value));
                                },
                                items: state
                                        .masterDataModel
                                        ?.masterData
                                        ?.masterReferenceAll
                                        ?.province
                                        ?.masterReference ??
                                    [],
                                errorText: isCheck == true &&
                                        state.provinceId.isNotValid
                                    ? 'Mohon diisi'
                                    : null,
                              );
                            },
                          ),
                          if (state.provinceId.isValid)
                            const SizedBox(height: 8),
                          BlocBuilder<AddCandidatePageBloc,
                              AddCandidatePageState>(
                            buildWhen: (current, previous) =>
                                current.cityId != previous.cityId ||
                                current.provinceId != previous.provinceId ||
                                current.masterDataModel !=
                                    previous.masterDataModel,
                            builder: (context, state) {
                              return state.provinceId.isValid
                                  ? DropDownGeneralSecond(
                                      title: 'Kota',
                                      // readOnly: state.provinceId.isValid
                                      //     ? false
                                      //     : true,
                                      icon: const Icon(
                                        Icons.account_balance_rounded,
                                        color: AclColors.greyDarkFontColor,
                                      ),
                                      onChanged: (CityMasterReference value) {
                                        getIt<AddCandidatePageBloc>()
                                            .add(CityInputEvent(value));
                                      },
                                      items: state
                                              .masterDataModel
                                              ?.masterData
                                              ?.masterReferenceAll
                                              ?.city
                                              ?.masterReference
                                              ?.where((element) =>
                                                  element.referTo ==
                                                  state.provinceId.value)
                                              .toList() ??
                                          [],
                                      errorText: isCheck == true &&
                                              state.cityId.isNotValid
                                          ? 'Mohon diisi'
                                          : null,
                                    )
                                  : Container();
                            },
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<AddCandidatePageBloc,
                              AddCandidatePageState>(
                            buildWhen: (current, previous) =>
                                current.occupationId != previous.occupationId ||
                                current.masterDataModel !=
                                    previous.masterDataModel,
                            builder: (context, state) {
                              return DropDownGeneralThird(
                                title: 'Pekerjaan',
                                icon: const Icon(
                                  Icons.work,
                                  color: AclColors.greyDarkFontColor,
                                ),
                                onChanged:
                                    (CheckingstatusMasterReference value) {
                                  getIt<AddCandidatePageBloc>()
                                      .add(OccupationInputEvent(value));
                                },
                                items: state
                                        .masterDataModel
                                        ?.masterData
                                        ?.masterReferenceAll
                                        ?.occupationtype
                                        ?.masterReference ??
                                    [],
                                errorText: isCheck == true &&
                                        state.occupationId.isNotValid
                                    ? 'Mohon diisi'
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text(
                                "Apakah Anda pernah bekerja di perusahaan asuransi jiwa sebelumnya?"),
                            value: checkedPrevCompanyAAJI,
                            onChanged: (newValue) {
                              setState(() {
                                checkedPrevCompanyAAJI = newValue ?? false;
                              });
                              getIt<AddCandidatePageBloc>().add(
                                  AajiCheckedInputEvent(newValue ?? false));
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                          if (checkedPrevCompanyAAJI) const SizedBox(height: 8),
                          if (checkedPrevCompanyAAJI)
                            DropDownGeneral(
                              title: 'Perusahaan sebelumnya',
                              isMandatory: checkedPrevCompanyAAJI,
                              readOnly: !checkedPrevCompanyAAJI,
                              icon: const Icon(
                                Icons.add_chart,
                                color: AclColors.greyDarkFontColor,
                              ),
                              onChanged: (AajicityMasterReference value) {
                                getIt<AddCandidatePageBloc>()
                                    .add(AajiPrevCompanyInputEvent(value));
                              },
                              items: state
                                      .masterDataModel
                                      ?.masterData
                                      ?.masterReferenceAll
                                      ?.prevcompany
                                      ?.masterReference ??
                                  [],
                              errorText: isCheck && state.prevCompanyAAJIId.isNotValid
                                  ? 'Mohon diisi'
                                  : null,
                            ),
                          const SizedBox(height: 8),
                          TextInput(
                            isMandatory: checkedPrevCompanyAAJI ||
                                state.imageLicenceAAJI.isValid,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            icon: const Icon(Icons.add_card_rounded),
                            labelText: "No lisensi AAJI",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(AajiNoInputEvent(value));
                            },
                            validator: (String? value) {
                              if (state.noLicenceAAJI.isNotValid ||
                                  (isCheck &&
                                      state.imageLicenceAAJI.isValid &&
                                      state.noLicenceAAJI.value == '') ||
                                  (isCheck &&
                                      checkedPrevCompanyAAJI &&
                                      state.noLicenceAAJI.value == '')) {
                                return state.noLicenceAAJI.invalidAajiNo;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          CustomImagePicker(
                            title: 'Foto Lisensi AAJI',
                            isMandatory: checkedPrevCompanyAAJI ||
                                (state.noLicenceAAJI.isValid &&
                                    state.noLicenceAAJI.value != ''),
                            onImagePicked: (value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(AajiImageInputEvent(value));
                            },
                            errorText: checkedPrevCompanyAAJI &&
                                    isCheck &&
                                    state.imageLicenceAAJI.isNotValid
                                ? 'Mohon diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text(
                                "Apakah Anda pernah bekerja di perusahaan asuransi syariah sebelumnya?"),
                            value: checkedPrevCompanyAASI,
                            onChanged: (newValue) {
                              setState(() {
                                checkedPrevCompanyAASI = newValue ?? false;
                              });
                              getIt<AddCandidatePageBloc>().add(
                                  AasiCheckedInputEvent(newValue ?? false));
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                          if (checkedPrevCompanyAASI) const SizedBox(height: 8),
                          if (checkedPrevCompanyAASI)
                            DropDownGeneral(
                              title: 'Perusahaan sebelumnya',
                              isMandatory: checkedPrevCompanyAASI,
                              readOnly: !checkedPrevCompanyAASI,
                              icon: const Icon(
                                Icons.add_chart,
                                color: AclColors.greyDarkFontColor,
                              ),
                              onChanged: (AajicityMasterReference value) {
                                getIt<AddCandidatePageBloc>()
                                    .add(AasiPrevCompanyInputEvent(value));
                              },
                              items: state
                                      .masterDataModel
                                      ?.masterData
                                      ?.masterReferenceAll
                                      ?.prevcompanyaasi
                                      ?.masterReference ??
                                  [],
                              errorText: isCheck && state.genderId.isNotValid
                                  ? 'Mohon diisi'
                                  : null,
                            ),
                          const SizedBox(height: 8),
                          TextInput(
                            isMandatory: checkedPrevCompanyAASI ||
                                state.imageLicenceAASI.isValid,
                            maxLength: 16,
                            keyboardType: TextInputType.phone,
                            icon: const Icon(Icons.add_card_rounded),
                            labelText: "No lisensi AASI",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(AasiNoInputEvent(value));
                            },
                            validator: (String? value) {
                              if (state.noLicenceAASI.isNotValid ||
                                  (isCheck &&
                                      state.imageLicenceAASI.isValid &&
                                      state.noLicenceAASI.value == '') ||
                                  (isCheck &&
                                      checkedPrevCompanyAASI &&
                                      state.noLicenceAASI.value == '')) {
                                return state.noLicenceAASI.invalidAasiNo;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          CustomImagePicker(
                            title: 'Foto Lisensi AASI',
                            isMandatory: checkedPrevCompanyAASI ||
                                (state.noLicenceAASI.isValid &&
                                    state.noLicenceAASI.value != ''),
                            onImagePicked: (value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(AasiImageInputEvent(value));
                            },
                            errorText: checkedPrevCompanyAASI &&
                                    isCheck &&
                                    state.imageLicenceAASI.isNotValid
                                ? 'Mohon diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text(
                                "Apakah Anda berminat untuk mengajukan lisensi asuransi umum?"),
                            value: checkedValueAAUI,
                            onChanged: (newValue) {
                              setState(() {
                                checkedValueAAUI = newValue ?? false;
                                checkedPrevCompanyAAUI = false;
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => aauiController.clear());
                              });

                              getIt<AddCandidatePageBloc>()
                                  .add(AauiCheckedInputEvent(false)); // cl
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                          checkedValueAAUI
                              ? const SizedBox(height: 8)
                              : Container(),
                          checkedValueAAUI
                              ? CheckboxListTile(
                                  title: const Text(
                                      "Apakah Anda pernah bekerja di perusahaan asuransi utama sebelumnya?"),
                                  value: checkedPrevCompanyAAUI,
                                  onChanged: (newValue) {
                                    setState(() {
                                      checkedPrevCompanyAAUI =
                                          newValue ?? false;
                                    });
                                    if (newValue = true) {
                                      getIt<AddCandidatePageBloc>()
                                          .add(AauiCheckedInputEvent(newValue));
                                    } else {
                                      setState(() {
                                        checkedPrevCompanyAAUI = false;
                                      });
                                      getIt<AddCandidatePageBloc>()
                                          .add(AauiCheckedInputEvent(false));
                                      getIt<AddCandidatePageBloc>().add(
                                          AauiPrevCompanyInputEvent(
                                              AajicityMasterReference()));
                                      getIt<AddCandidatePageBloc>()
                                          .add(AauiNoInputEvent(''));
                                      getIt<AddCandidatePageBloc>()
                                          .add(AauiImageInputEvent(''));
                                    }
                                  },
                                  controlAffinity: ListTileControlAffinity
                                      .leading, //  <-- leading Checkbox
                                )
                              : Container(),
                          checkedPrevCompanyAAUI
                              ? const SizedBox(height: 8)
                              : Container(),
                          checkedPrevCompanyAAUI
                              ? DropDownGeneral(
                                  title: 'Perusahaan sebelumnya',
                                  isMandatory: checkedPrevCompanyAAUI,
                                  readOnly: !checkedPrevCompanyAAUI,
                                  icon: const Icon(
                                    Icons.add_chart,
                                    color: AclColors.greyDarkFontColor,
                                  ),
                                  onChanged: (AajicityMasterReference value) {
                                    getIt<AddCandidatePageBloc>()
                                        .add(AauiPrevCompanyInputEvent(value));
                                  },
                                  items: state
                                          .masterDataModel
                                          ?.masterData
                                          ?.masterReferenceAll
                                          ?.prevcompanyaaui
                                          ?.masterReference ??
                                      [],
                                  errorText:
                                      isCheck && state.genderId.isNotValid
                                          ? 'Mohon diisi'
                                          : null,
                                )
                              : Container(),
                          checkedValueAAUI
                              ? const SizedBox(height: 8)
                              : Container(),
                          checkedValueAAUI
                              ? TextInput(
                                  controller: aauiController,
                                  maxLength: 28,
                                  keyboardType: TextInputType.phone,
                                  isMandatory: checkedPrevCompanyAAUI ||
                                      state.imageLicenceAAUI.isValid,
                                  icon: const Icon(Icons.add_card_rounded),
                                  labelText: "No lisensi AAUI",
                                  onChanged: (String value) {
                                    getIt<AddCandidatePageBloc>()
                                        .add(AauiNoInputEvent(value));
                                  },
                                  validator: (String? value) {
                                    if (state.noLicenceAAUI.isNotValid ||
                                        (isCheck &&
                                            state.imageLicenceAAUI.isValid &&
                                            state.noLicenceAAUI.value == '') ||
                                        (isCheck &&
                                            checkedPrevCompanyAAUI &&
                                            state.noLicenceAAUI.value == '')) {
                                      return state.noLicenceAAUI.invalidAauiNo;
                                    }
                                    return null;
                                  },
                                )
                              : Container(),
                          checkedValueAAUI
                              ? const SizedBox(height: 8)
                              : Container(),
                          checkedValueAAUI
                              ? CustomImagePicker(
                                  title: 'Foto Lisensi AAUI',
                                  isMandatory: checkedPrevCompanyAAUI ||
                                      (state.noLicenceAAUI.isValid &&
                                          state.noLicenceAAUI.value != ''),
                                  onImagePicked: (value) {
                                    getIt<AddCandidatePageBloc>()
                                        .add(AauiImageInputEvent(value));
                                  },
                                  errorText: checkedPrevCompanyAAUI &&
                                          isCheck &&
                                          state.imageLicenceAAUI.isNotValid
                                      ? 'Mohon diisi'
                                      : null,
                                )
                              : Container(),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text("Menikah"),
                            value: checkedValueMarriage,
                            onChanged: (newValue) {
                              setState(() {
                                checkedValueMarriage = newValue ?? true;
                                if (newValue == false) {
                                  if (isCheck) {
                                    formKey.currentState!.validate();
                                  }
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) => [
                                            noIdentitySpouse.clear(),
                                            firstNameSpouse.clear(),
                                            middleNameSpouse.clear(),
                                            lastNameSpouse.clear(),
                                            dobSpouse.clear(),
                                          ]);
                                  setState(() {
                                    initialGenderSpouse = null;
                                    initialRelationSpouse = null;
                                    isInitGender = true;
                                    isInitRelation = true;
                                  });
                                }
                              });

                              getIt<AddCandidatePageBloc>().add(
                                  MarriedCheckedInputEvent(newValue ?? true));
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            controller: noIdentitySpouse,
                            icon: const Icon(Icons.person),
                            isMandatory: checkedValueMarriage,
                            readOnly: !checkedValueMarriage,
                            keyboardType: TextInputType.phone,
                            maxLength: 16,
                            labelText: "No KTP Pasangan",
                            // initialValue: postTitle,
                            validator: (String? value) {
                              if (checkedValueMarriage) {
                                if (state.identityNoPartner.isNotValid) {
                                  return state
                                      .identityNoPartner.invalidIdentityNo;
                                }
                                return null;
                              } else {
                                return null;
                              }
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(PartnerIdentityNoInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            controller: firstNameSpouse,
                            icon: const Icon(Icons.person),
                            labelText: "Nama Depan(sesuai KTP)",
                            isMandatory: checkedValueMarriage,
                            readOnly: !checkedValueMarriage,
                            validator: (String? value) {
                              if (checkedValueMarriage) {
                                if (value!.isNotEmpty) return null;
                                return "Mohon diisi";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(FirstNamePartnerInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            controller: middleNameSpouse,
                            isMandatory: false,
                            readOnly: !checkedValueMarriage,
                            icon: const Icon(Icons.person),
                            labelText: "Nama tengah(sesuai KTP)",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(MiddleNamePartnerInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          TextInput(
                            controller: lastNameSpouse,
                            isMandatory: false,
                            readOnly: !checkedValueMarriage,
                            icon: const Icon(Icons.person),
                            labelText: "Nama belakang(sesuai KTP)",
                            onChanged: (String value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(LastNamePartnerInputEvent(value));
                            },
                          ),
                          const SizedBox(height: 8),
                          DateTimePickerForm(
                            controller: dobSpouse,
                            labelText: "Pilih Tanggal",
                            title: "Tanggal lahir pasangan",
                            errorText:
                                isCheck && state.dobPartner.isNotValid &&
                                    checkedValueMarriage
                                    ? 'Mohon diisi'
                                    : null,
                            isMandatory: checkedValueMarriage,
                            readOnly: !checkedValueMarriage,
                            selectedDateTime: (DateTime date) {
                              var month = date.month.toString().length == 1
                                  ? '0${date.month}'
                                  : date.month;
                              var day = date.day.toString().length == 1
                                  ? '0${date.day}'
                                  : date.day;
                              var dateTime = "${date.year}-$month-$day";
                              getIt<AddCandidatePageBloc>()
                                  .add(DobPartnerInputEvent(dateTime));
                            },
                            validator: (String? value) {
                              if (checkedValueMarriage) {
                                if (value!.isNotEmpty) return null;
                                return "Mohon diisi";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          DropDownGeneral(
                            title: 'Jenis kelamin',
                            isMandatory: checkedValueMarriage,
                            readOnly: !checkedValueMarriage,
                            icon: const Icon(
                              Icons.add_chart,
                              color: AclColors.greyDarkFontColor,
                            ),
                            onChanged: (AajicityMasterReference value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(GenderPartnerInputEvent(value));
                              isInitGender = false;
                            },
                            items: state
                                    .masterDataModel
                                    ?.masterData
                                    ?.masterReferenceAll
                                    ?.gender
                                    ?.masterReference ??
                                [],
                            errorText: isCheck &&
                                    state.genderId.isNotValid &&
                                    checkedValueMarriage
                                ? 'Mohon diisi'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          DropDownGeneral(
                            title: 'Hubungan Dengan Kandidat',
                            isMandatory: checkedValueMarriage,
                            readOnly: !checkedValueMarriage,
                            icon: const Icon(
                              Icons.add_chart,
                              color: AclColors.greyDarkFontColor,
                            ),
                            onChanged: (AajicityMasterReference value) {
                              getIt<AddCandidatePageBloc>()
                                  .add(RelationPartnerInputEvent(value));
                              isInitRelation = false;
                            },
                            items: state
                                    .masterDataModel
                                    ?.masterData
                                    ?.masterReferenceAll
                                    ?.relation
                                    ?.masterReference ??
                                [],
                            errorText: isCheck &&
                                    state.relationId.isNotValid &&
                                    checkedValueMarriage
                                ? 'Mohon diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            width: MediaQuery.of(context).size.width,
                            child: AdaptiveButton(
                              titleText:"Selanjutnya".toCapital,
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  getIt<AddCandidatePageBloc>()
                                      .add(AddAgentSubmittedEvent());
                                }
                                setState(() {
                                  isCheck = true;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  state.submitStatus.isInProgress
                      ? state.loadingMessage == 'waiting-fetch-master'
                          ? Container(
                              color: Colors.white.withAlpha(90),
                              child: const Center(
                                  child: ProgressDialog(
                                title: 'Sedang memuat data...',
                                isProgressed: true,
                              )))
                          : Container(
                              color: Colors.white.withAlpha(90),
                              child: const Center(
                                  child: ProgressDialog(
                                title: 'Sedang memproses data...',
                                isProgressed: true,
                              )))
                      : Container(),

                  // state.submitStatus.isFailure
                  //     ? showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return RetryDialog(
                  //       title: state.message ?? "Error",
                  //       onCancelPressed: () =>Navigator.pop(context),
                  //     );
                  //   },
                  // ): Container()
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
