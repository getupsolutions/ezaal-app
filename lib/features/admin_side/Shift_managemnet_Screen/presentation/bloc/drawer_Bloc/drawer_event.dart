import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToPage extends NavigationEvent {
  final int pageIndex;

  const NavigateToPage(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}
