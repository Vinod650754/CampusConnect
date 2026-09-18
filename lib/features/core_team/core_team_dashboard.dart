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

class CoreTeamDashboard extends StatefulWidget { const CoreTeamDashboard({super.key}); @override State<CoreTeamDashboard> createState()=>_CoreTeamDashboardState(); }
class _CoreTeamDashboardState extends State<CoreTeamDashboard> {
  int _selectedIndex=0;
  static const _destinations=[
    AppShellDestination(label:'Dashboard',icon:Icons.grid_view_outlined,activeIcon:Icons.grid_view_rounded),
    AppShellDestination(label:'Events',icon:Icons.event_outlined,activeIcon:Icons.event_rounded),
    AppShellDestination(label:'Attendance',icon:Icons.fact_check_outlined,activeIcon:Icons.fact_check_rounded),
    AppShellDestination(label:'Updates',icon:Icons.campaign_outlined,activeIcon:Icons.campaign_rounded),
    AppShellDestination(label:'Me',icon:Icons.person_outline_rounded,activeIcon:Icons.person_rounded),
  ];
  @override Widget build(BuildContext context)=>AppShell(roleLabel:'CORE TEAM',destinations:_destinations,selectedIndex:_selectedIndex,onDestinationSelected:(i)=>setState(()=>_selectedIndex=i),child:_page());
  Widget _page(){switch(_selectedIndex){case 1:return const EventListScreen(role:'CORE_TEAM',embedded:true);case 2:return const AttendanceScannerScreen(role:'CORE_TEAM',embedded:true);case 3:return const AnnouncementListScreen(role:'CORE_TEAM',embedded:true);case 4:return const ProfileScreen(role:'CORE_TEAM',embedded:true);default:return _dashboard();}}
  Widget _dashboard()=>SingleChildScrollView(physics:const BouncingScrollPhysics(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const DashboardHeader(eyebrow:'Club operations',title:'Operate with the team.',subtitle:'Manage assigned events, attendance, participants, announcements and event media.'),
    const SizedBox(height:AppDimens.space24),
    Wrap(spacing:12,runSpacing:12,children:const[
      SizedBox(width:250,child:DashboardMetricCard(label:'Assigned events',value:'Live',supportingText:'Create and manage your event lifecycle',icon:Icons.event_available_rounded)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Attendance',value:'Live',supportingText:'Review and update participant records',icon:Icons.fact_check_outlined,accentColor:AppColors.success)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Participants',value:'Live',supportingText:'Review registrations from event details',icon:Icons.groups_rounded,accentColor:AppColors.accent)),
      SizedBox(width:250,child:DashboardMetricCard(label:'Announcements',value:'Live',supportingText:'Create and publish team updates',icon:Icons.campaign_outlined,accentColor:AppColors.warning)),
    ]),
    const SizedBox(height:AppDimens.space28),
    const SectionTitle(title:'Operations',subtitle:'Every action below connects to the real API.'),
    const SizedBox(height:AppDimens.space16),
    Wrap(spacing:12,runSpacing:12,children:[
      SizedBox(width:300,child:QuickActionCard(title:'Events',subtitle:'Create, edit, publish and manage assigned events.',icon:Icons.event_rounded,onTap:()=>setState(()=>_selectedIndex=1))),
      SizedBox(width:300,child:QuickActionCard(title:'Attendance',subtitle:'Scan the staff QR to mark your attendance.',icon:Icons.fact_check_rounded,onTap:()=>setState(()=>_selectedIndex=2))),
      SizedBox(width:300,child:QuickActionCard(title:'Participants',subtitle:'Open an event to review registrations and status.',icon:Icons.groups_rounded,onTap:()=>setState(()=>_selectedIndex=1))),
      SizedBox(width:300,child:QuickActionCard(title:'Gallery',subtitle:'Upload and manage event photos.',icon:Icons.photo_library_rounded,onTap:()=>Get.to(()=>const GalleryScreen(role:'CORE_TEAM')))),
      SizedBox(width:300,child:QuickActionCard(title:'Updates',subtitle:'Create and publish announcements.',icon:Icons.campaign_rounded,onTap:()=>setState(()=>_selectedIndex=3))),
      SizedBox(width:300,child:QuickActionCard(title:'Profile',subtitle:'Edit your account or log out.',icon:Icons.person_rounded,onTap:()=>setState(()=>_selectedIndex=4))),
    ]),
  ]));
}
