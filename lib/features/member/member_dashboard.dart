import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../announcements/announcement_list_screen.dart';
import '../attendance/attendance_scanner_screen.dart';
import '../events/event_list_screen.dart';
import '../gallery/gallery_screen.dart';
import '../profile/profile_screen.dart';
import '../registrations/registration_list_screen.dart';

class MemberDashboard extends StatefulWidget { const MemberDashboard({super.key}); @override State<MemberDashboard> createState()=>_MemberDashboardState(); }
class _MemberDashboardState extends State<MemberDashboard>{
  int _selectedIndex=0;
  static const _destinations=[
    AppShellDestination(label:'Home',icon:Icons.home_outlined,activeIcon:Icons.home_rounded),
    AppShellDestination(label:'Events',icon:Icons.event_outlined,activeIcon:Icons.event_rounded),
    AppShellDestination(label:'Registrations',icon:Icons.event_note_outlined,activeIcon:Icons.event_note_rounded),
    AppShellDestination(label:'Updates',icon:Icons.campaign_outlined,activeIcon:Icons.campaign_rounded),
    AppShellDestination(label:'Me',icon:Icons.person_outline_rounded,activeIcon:Icons.person_rounded),
  ];
  @override Widget build(BuildContext context)=>AppShell(roleLabel:'MEMBER',destinations:_destinations,selectedIndex:_selectedIndex,onDestinationSelected:(i)=>setState(()=>_selectedIndex=i),child:_page());
  Widget _page(){switch(_selectedIndex){case 1:return const EventListScreen(role:'MEMBER',embedded:true);case 2:return const RegistrationListScreen(role:'MEMBER',embedded:true);case 3:return const AnnouncementListScreen(role:'MEMBER',embedded:true);case 4:return const ProfileScreen(role:'MEMBER',embedded:true);default:return _dashboard();}}
  Widget _dashboard()=>SingleChildScrollView(physics:const BouncingScrollPhysics(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const DashboardHeader(eyebrow:'Club member',title:'Your club space.',subtitle:'Discover events, register, scan attendance, view updates and manage your profile.'),
    const SizedBox(height:AppDimens.space24),
    Wrap(spacing:12,runSpacing:12,children:const[
      SizedBox(width:250,child:DashboardMetricCard(label:'Events',value:'Live',supportingText:'Discover upcoming campus events',icon:Icons.event_available_rounded)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Registrations',value:'Live',supportingText:'Track your event registrations',icon:Icons.event_note_rounded)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Attendance',value:'Live',supportingText:'Check in with event QR',icon:Icons.qr_code_scanner_rounded,accentColor:AppColors.success)),
    ]),
    const SizedBox(height:AppDimens.space28),
    const SectionTitle(title:'Quick actions',subtitle:'Real member operations.'),const SizedBox(height:AppDimens.space16),
    Wrap(spacing:12,runSpacing:12,children:[
      SizedBox(width:300,child:QuickActionCard(title:'Explore events',subtitle:'Open events and register for eligible events.',icon:Icons.event_rounded,onTap:()=>setState(()=>_selectedIndex=1))),
      SizedBox(width:300,child:QuickActionCard(title:'My registrations',subtitle:'See confirmed, pending, attended or cancelled registrations.',icon:Icons.event_note_rounded,onTap:()=>setState(()=>_selectedIndex=2))),
      SizedBox(width:300,child:QuickActionCard(title:'Scan attendance',subtitle:'Check in to an event using its QR code.',icon:Icons.qr_code_scanner_rounded,onTap:()=>Get.to(()=>const AttendanceScannerScreen(role:'MEMBER')))),
      SizedBox(width:300,child:QuickActionCard(title:'Gallery',subtitle:'Browse club event media.',icon:Icons.photo_library_rounded,onTap:()=>Get.to(()=>const GalleryScreen(role:'MEMBER')))),
      SizedBox(width:300,child:QuickActionCard(title:'Profile',subtitle:'Edit your profile, password or log out.',icon:Icons.person_rounded,onTap:()=>setState(()=>_selectedIndex=4))),
    ]),
  ]));
}
