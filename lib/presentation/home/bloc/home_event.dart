
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// Event để tải dữ liệu cho trang chủ
class LoadHomeData extends HomeEvent {}
