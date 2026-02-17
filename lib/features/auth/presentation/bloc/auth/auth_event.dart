import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.emailChanged(String email) = EmailChanged;
  const factory AuthEvent.passwordChanged(String password) = PasswordChanged;
  const factory AuthEvent.loginSubmitted() = LoginSubmitted;
}




// abstract class DrawerEvent {}

// class ToggleDrawerEvent extends DrawerEvent {
//   final bool showDrawer;
//   ToggleDrawerEvent({required this.showDrawer});
// }

// class ToggleDrawerWidgetEvent extends DrawerEvent {
//   final DrawerWidgets drawerWidgets;
//   ToggleDrawerWidgetEvent({required this.drawerWidgets});
// }

// class ToggleDrawerBothEvent extends DrawerEvent {
//   final DrawerWidgets drawerWidgets;
//   final bool showDrawer;
//   ToggleDrawerBothEvent({
//     required this.drawerWidgets,
//     required this.showDrawer,
//   });
// }
