import 'package:flutter/material.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_cubit.dart';
import 'package:myflexbox/repos/models/booking.dart';

class CurrentLockerQRView extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;
  final MemoryImage qr;

  const CurrentLockerQRView({Key key, this.booking, this.cubit, this.qr})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        children: [
          Container(height: 5),
          QrViewMenuBar(booking: booking, cubit: cubit),
          QrViewImage(qr: qr, booking: booking),
          Container(height: 50)
        ],
      ),
    );
  }
}

class QrViewImage extends StatelessWidget {
  final MemoryImage qr;
  final Booking booking;

  const QrViewImage({Key key, this.qr, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity:
          booking.state == "BOOKING_CREATED" || booking.state == "NOT_COLLECTED"
              ? 1
              : .3,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          image: new DecorationImage(
            fit: BoxFit.cover,
            image: qr,
          ),
        ),
      ),
    );
  }
}

class QrViewMenuBar extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;

  const QrViewMenuBar({Key key, this.booking, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: FlatButton(
          onPressed: () {
            cubit.showDefault();
          },
          child: Icon(Icons.close),
        )),
        Expanded(
          child: Center(
              child: Text(
                  booking.state == "COLLECTED"
                      ? "Bereits abgeholt"
                      : booking.state == "BOOKING_CREATED"
                          ? "Einlagern"
                          : booking.state == "NOT_COLLECTED"
                              ? "Abholen"
                              : "abgebrochen",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.grey))),
          flex: 2,
        ),
        Expanded(
          child: FlatButton(
            onPressed: () {},
            child: Text(""),
          ),
        )
      ],
    );
  }
}
