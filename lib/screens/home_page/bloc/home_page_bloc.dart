import 'dart:async';

import 'package:acl_flutter/data/model/agent/agent_model.dart';
import 'package:acl_flutter/data/model/login_model/login_model.dart';
import 'package:acl_flutter/data/model/notification_model/notification_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/local_storage/secure_storage/secure_storage.dart';
import '../../../core/router/routes.dart';
import '../../../data/repository/agent/agent_repository.dart';
import '../../../data/repository/notification/notification_repository.dart';

part 'home_page_event.dart';

part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final AgentRepository agentRepository;
  final NotificationRepository notificationRepository;

  HomePageBloc({required this.agentRepository,required this.notificationRepository}) : super(const HomePageState()) {
    on<FetchListMyAgentEvent>(fetchListAgent);
    on<FetchListNotifyEvent>(fetchListNotify);
  }

  Future<void> fetchListAgent(
      FetchListMyAgentEvent event, Emitter<HomePageState> emit) async {
    emit(state.copyWith(status: HomePageStatus.loading));
    try {
      LoginModel loginModel = await SecureStorage().getUser();
      final result = await agentRepository.fetchListMyAgent(
          leaderCode: loginModel.uid ?? '');
      result.when(success: (response) {
        List<AgentModel> listAgent = response.data;
        emit(state.copyWith(
            listAgentModel: listAgent,
            status: HomePageStatus.success));
      }, failure: (error) {
        emit(state.copyWith(status: HomePageStatus.error, errorMessage: error));
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchListNotify(
      FetchListNotifyEvent event, Emitter<HomePageState> emit) async {
    emit(state.copyWith(status: HomePageStatus.loading));
    try {
      LoginModel loginModel = await SecureStorage().getUser();
      final result = await notificationRepository.fetchListNotify(
          leaderCode: loginModel.uid ?? '');
      result.when(success: (response) {
        List<NotificationModel> listNotify = response.data;
        emit(state.copyWith(
            listNotify: listNotify,
            status: HomePageStatus.success));
      }, failure: (error) {
        emit(state.copyWith(status: HomePageStatus.error, errorMessage: error));
      });
    } catch (error) {
      print(error);
    }
  }
}