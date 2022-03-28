import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_cubit.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_state.dart';
import 'package:myflexbox/Screens/current_locker_detail/widgets/default_view.dart';
import 'package:myflexbox/Screens/current_locker_detail/widgets/shareLocker_view.dart';
import 'package:myflexbox/Screens/current_locker_detail/widgets/qr_view.dart';

class CurrentLockerDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LockerDetailCubit, LockerDetailState>(
      builder: (context, state) {
        LockerDetailCubit cubit = context.read<LockerDetailCubit>();
        if (state is LockerDetailStateDefault) {
          return CurrentLockerDefaultView(booking: state.booking, cubit: cubit);
        } else if (state is LockerDetailStateShare) {
          return CurrentLockerShareView(booking: state.booking, cubit: cubit);
        } else if (state is LockerDetailStateQR) {
          MemoryImage image = state.qr;
          return CurrentLockerQRView(
              booking: state.booking, cubit: cubit, qr: image);
        } else {
          return LockerDetailLoadingView();
        }
      },
    );
  }
}

class LockerDetailLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        children: [
          Row(
            children: [
              Text(""),
            ],
          ),
          Container(
            height: 300,
            child: Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                ),
                height: 30.0,
                width: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
