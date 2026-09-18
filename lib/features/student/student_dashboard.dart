import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../announcements/announcement_list_screen.dart';
import '../attendance/attendance_scanner_screen.dart';
import '../certificates/certificate_list_screen.dart';
import '../events/event_list_screen.dart';
import '../gallery/gallery_screen.dart';
import '../profile/profile_screen.dart';
import '../registrations/registration_list_screen.dart';

class StudentDashboard extends StatefulWidget { const StudentDashboard({super.key}); @override State<StudentDashboard> createState()=>_StudentDashboardState(); }
class _StudentDashboardState extends State<StudentDashboard>{
  int _selectedIndex=0;
  static const _destinations=[
    AppShellDestination(label:'Home',icon:Icons.home_outlined,activeIcon:Icons.home_rounded),
    AppShellDestination(label:'Events',icon:Icons.event_outlined,activeIcon:Icons.event_rounded),
    AppShellDestination(label:'Registrations',icon:Icons.event_note_outlined,activeIcon:Icons.event_note_rounded),
    AppShellDestination(label:'Updates',icon:Icons.campaign_outlined,activeIcon:Icons.campaign_rounded),
    AppShellDestination(label:'Me',icon:Icons.person_outline_rounded,activeIcon:Icons.person_rounded),
  ];
  @override Widget build(BuildContext context)=>AppShell(roleLabel:'STUDENT',destinations:_destinations,selectedIndex:_selectedIndex,onDestinationSelected:(i)=>setState(()=>_selectedIndex=i),child:_page());
  Widget _page(){switch(_selectedIndex){case 1:return const EventListScreen(role:'STUDENT',embedded:true);case 2:return const RegistrationListScreen(role:'STUDENT',embedded:true);case 3:return const AnnouncementListScreen(role:'STUDENT',embedded:true);case 4:return const ProfileScreen(role:'STUDENT',embedded:true);default:return _dashboard();}}
  Widget _dashboard()=>SingleChildScrollView(physics:const BouncingScrollPhysics(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const DashboardHeader(eyebrow:'Campus participant',title:'Your campus starts here.',subtitle:'Discover events, register, follow announcements, check attendance and manage your profile.'),
    const SizedBox(height:AppDimens.space24),
    Wrap(spacing:12,runSpacing:12,children:const[
      SizedBox(width:250,child:DashboardMetricCard(label:'Events',value:'Live',supportingText:'Discover and register for events',icon:Icons.event_available_rounded)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Registrations',value:'Live',supportingText:'Track your participation',icon:Icons.event_note_rounded)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Certificates',value:'Live',supportingText:'View certificates issued to you',icon:Icons.workspace_premium_outlined,accentColor:AppColors.warning)),
    ]),
    const SizedBox(height:AppDimens.space28),const SectionTitle(title:'Student tools',subtitle:'Real API-backed student operations.'),const SizedBox(height:AppDimens.space16),
    Wrap(spacing:12,runSpacing:12,children:[
      SizedBox(width:300,child:QuickActionCard(title:'Explore events',subtitle:'Browse events and register.',icon:Icons.event_rounded,onTap:()=>setState(()=>_selectedIndex=1))),
      SizedBox(width:300,child:QuickActionCard(title:'My registrations',subtitle:'Track your event registrations.',icon:Icons.event_note_rounded,onTap:()=>setState(()=>_selectedIndex=2))),
      SizedBox(width:300,child:QuickActionCard(title:'Scan attendance',subtitle:'Use the event QR to record attendance.',icon:Icons.qr_code_scanner_rounded,onTap:()=>Get.to(()=>const AttendanceScannerScreen(role:'STUDENT')))),
      SizedBox(width:300,child:QuickActionCard(title:'Certificates',subtitle:'View and verify your certificates.',icon:Icons.workspace_premium_rounded,onTap:()=>Get.to(()=>const CertificateListScreen(role:'STUDENT')))),
      SizedBox(width:300,child:QuickActionCard(title:'Gallery',subtitle:'Browse campus event media.',icon:Icons.photo_library_rounded,onTap:()=>Get.to(()=>const GalleryScreen(role:'STUDENT')))),
      SizedBox(width:300,child:QuickActionCard(title:'Profile',subtitle:'Edit your account or log out.',icon:Icons.person_rounded,onTap:()=>setState(()=>_selectedIndex=4))),
    ]),
  ]));
}
