import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/home/widgets/app_bar.dart';
import 'package:myflexbox/Screens/home/widgets/bottom_navigation_bar.dart';
import 'package:myflexbox/Screens/profile/profile_page.dart';
import 'package:myflexbox/Screens/rent_locker/rent_locker_page.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:myflexbox/cubits/bottom_nav/bottom_nav_state.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';
import 'package:myflexbox/repos/rent_locker_repository.dart';

import '../current_lockers/current_locker_page.dart';
import '../notification/notification_page.dart';

// Root of the the HomeView Route.
// Here, a PageView is implemented and connected with the bottom nav bar
// Depending on the index of the page, a different View is returned.
// The returned Views are wrapped in their respective BlocProviders, to preserve
// their states on page changes.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // pageController is responsible for page loading and changing
  final PageController _pageController = PageController();
  // bool used to let listener know, that a page transition is in progress
  bool stoppedAnimating = true;

  //List of pages that are Viewed by the pageController
  final List<Widget> pages = [
      CurrentLockersPage(),
      RentLockerPage(),
      NotificationPage(),
      ProfilePage(),
    ];


  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: CustomAppBar(),
        bottomNavigationBar: BottomGoogleNavigationBar(),
        body: BlocConsumer<BottomNavCubit, BottomNavState>(
            //if the BottomNavState has changed, the pageView animates
            // to the pageIndex of the state. While in progress, stoppedAnimating
            // is set to true
            listener: (context, state) {
              stoppedAnimating = false;
              _pageController.animateToPage(state.pageIndex,
              duration: Duration(milliseconds: 500), curve: Curves.easeOut).then((_)  {
                stoppedAnimating = true;
              });
            },
            builder: (context, state) {
            // Here, all BlocProviders are provided for the pages in the pageView
            // It has to happen here, because the pageView rebuilds the pages
            // every time, so the state has to be stored a layer above taht.
            return MultiBlocProvider(
                providers: [
                  BlocProvider<RentLockerCubit>(
                    create: (context) => RentLockerCubit(RentLockerRepository())..getCurrentLocation(),
                  ),
                  BlocProvider<CurrentLockerCubit>(
                    create: (context) => CurrentLockerCubit()..loadData(),
                  ),
                ],
              child: PageView(
                // This listener enables swiping, while keeping the bottom
                // nav bar up to date
                onPageChanged: (index) {
                  // only if no transition is currently in progress
                  if(stoppedAnimating){
                    final bottomNavCubit = context.read<BottomNavCubit>();
                    bottomNavCubit.changePage(index);
                  }
                },
                controller: _pageController,
                children: pages,
                physics: state is AddLockerNavState
                    ? NeverScrollableScrollPhysics()
                    : ScrollPhysics(),
              ));
        }),
    );
  }

}
