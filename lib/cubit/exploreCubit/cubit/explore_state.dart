part of 'explore_cubit.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();
}

class ExploreInitial extends ExploreState {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class ExploreRedirect extends ExploreState {
  int index;

  ExploreRedirect({this.index});

  @override
  List<Object> get props => [];
}
