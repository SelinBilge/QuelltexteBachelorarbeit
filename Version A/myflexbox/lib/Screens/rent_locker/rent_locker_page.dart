import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/rent_locker/widgets/rent_locker_filter_form.dart';
import 'package:myflexbox/Screens/rent_locker/widgets/rent_locker_list_view.dart';
import 'package:myflexbox/Screens/rent_locker/widgets/rent_locker_map_view.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';

class RentLockerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentLockerCubit, RentLockerState>(
      builder: (context, state) {
        return Column(
          children: [
            FilterForm(),
            state is FilterRentLockerState ||
                    state is FilterRentLockerLoadingState
                ? RentLockerListView()
                : RentLockerMapView()
          ],
        );
      },
    );
  }
}
