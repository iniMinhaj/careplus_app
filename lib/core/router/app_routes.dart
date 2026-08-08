/// Centralized route path constants for [GoRouter] config and navigation
/// call sites, so paths are never hand-typed in more than one place.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const roleSelect = '/role-select';

  static const home = '/home';
  static const appointments = '/appointments';
  static const medicines = '/medicines';
  static const profile = '/profile';

  static const doctorDetail = '/doctor/:doctorId';
  static String doctorDetailPath(String doctorId) => '/doctor/$doctorId';

  static const bookingConfirm = '/booking/confirm';
  static const bookingPayment = '/booking/payment';
  static const bookingSuccess = '/booking/success';

  static const appointmentDetail = '/appointments/detail';
  static const joinCall = '/appointments/call';

  static const profileEdit = '/profile/edit';
  static const paymentHistory = '/profile/payments';

  static const medicineAdd = '/medicines/add';
  static const medicineAdherence = '/medicines/adherence';

  static const healthRecords = '/health-records';
  static const healthRecordDetail = '/health-records/detail';
}
