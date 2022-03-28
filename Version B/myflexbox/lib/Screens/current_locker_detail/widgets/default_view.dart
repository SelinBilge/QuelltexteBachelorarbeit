import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/cubits/auth/auth_state.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_cubit.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_state.dart';
import 'package:myflexbox/repos/models/booking.dart';

class CurrentLockerDefaultView extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;

  const CurrentLockerDefaultView({Key key, this.booking, this.cubit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
        List<String> favoriteIds = (state as AuthAuthenticated).user.favourites;
        return Column(
          children: [
            Container(height: 5),
            DefaultViewMenuBar(
                booking: booking, cubit: cubit, favoriteIds: favoriteIds),
            Container(height: 10),
            DescriptionView(booking: booking),
            Container(height: 20),
            SharedByFrom(
                booking: booking, cubit: cubit, favoriteIds: favoriteIds),
            Container(height: 10),
            BoxSizeView(booking: booking),
            Container(height: 45),
            DateRangeView(booking: booking),
            Container(height: 25),
            QRButton(cubit: cubit),
            Container(
              height: 30,
            ),
            MapViewText(),
            Container(
              height: 20,
            ),
            MapView()
          ],
        );
      }),
    );
  }
}

class SharedByFrom extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;
  final List<String> favoriteIds;

  const SharedByFrom({Key key, this.booking, this.cubit, this.favoriteIds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        labelText(),
        Container(width: 5),
        fromByText(),
      ],
    );
  }

  Widget labelText() {
    if (booking is BookingFrom) {
      return Text("geteilt von:", style: TextStyle(color: Colors.grey));
    } else if (booking is BookingTo) {
      return Text("geteilt mit:", style: TextStyle(color: Colors.black54));
    } else {
      return Container();
    }
  }

  Widget fromByText() {
    if (booking is BookingFrom) {
      return Container(
        child: Text((booking as BookingFrom).fromUser.name),
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.1),
            borderRadius: BorderRadius.all(Radius.circular(7))),
      );
    } else if (booking is BookingTo) {
      return Container(
        child: Row(
          children: [
            Text((booking as BookingTo).toUser.name),
            IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  Icons.close,
                  size: 15,
                  color: kPrimaryColor,
                ),
                onPressed: () {
                  cubit.deleteShare();
                })
          ],
        ),
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 5),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.1),
            borderRadius: BorderRadius.all(Radius.circular(7))),
      );
    } else {
      return Row(
        children: [
          Text("Mit niemanden geteilt,",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54)),
          TextButton(
              onPressed: () {
                cubit.showShare(favoriteIds);
              },
              child: Text("jetzt teilen"),
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(left: 3),
              ))
        ],
      );
    }
  }
}

class DescriptionView extends StatelessWidget {
  final Booking booking;

  const DescriptionView({Key key, this.booking}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      if (booking.parcelNumber == "") {

      return Container();
    } else {
      return Container(
        width: double.infinity,
        color: Colors.grey.withOpacity(.1),
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(booking.parcelNumber, textAlign: TextAlign.center)),
          ],
        ),
      );
    }
  }
}

class QRButton extends StatelessWidget {
  final LockerDetailCubit cubit;

  const QRButton({Key key, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        cubit.showQR();
      },
      color: kPrimaryColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_rounded, color: Colors.white),
          Container(width: 10),
          Text("QR-Code anzeigen", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class DateRangeView extends StatelessWidget {
  final Booking booking;

  const DateRangeView({Key key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(convertDate(booking.startTime),
                style: TextStyle(fontSize: 19)),
            Container(height: 5),
            Text("von", style: TextStyle(color: Colors.black54)),
          ],
        ),
        Container(width: 25),
        Column(
          children: [
            Text(convertDate(booking.endTime), style: TextStyle(fontSize: 19)),
            Container(height: 5),
            Text("bis", style: TextStyle(color: Colors.black54)),
          ],
        )
      ],
    );
  }

  String convertDate(String date) {
    var time = DateTime.parse(date);
    return time.day.toString() +
        "." +
        time.month.toString() +
        "." +
        time.year.toString();
  }
}

class BoxSizeView extends StatelessWidget {
  final Booking booking;

  const BoxSizeView({Key key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Fachgröße:", style: TextStyle(color: Colors.black54)),
        Container(width: 10),
        Icon(Icons.inbox, color: kPrimaryColor),
        SizedBox(width: 5,),
        Text(getBoxSize()),
      ],
    );
  }

  //TODO find out right sizes
  String getBoxSize() {
    int height = booking.compartmentHeight.toInt();
    print(height);
    if (height > 700) {
      return "L";
    } else if (height > 460) {
      return "M";
    } else {
      return "S";
    }
  }
}

class MapViewText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LockerDetailCubit, LockerDetailState>(
        builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: kPrimaryColor),
            Container(width: 180, child: Text(getAddress(state))),
            Spacer(),
            GestureDetector(
              onTap: () {
                var cubit = context.read<LockerDetailCubit>();
                if (state.locker != null) {
                  cubit.openGoogleMaps(
                      state.locker.latitude, state.locker.longitude);
                }
              },
              child: Row(
                children: [
                  Text("Route", style: TextStyle(color: kPrimaryColor)),
                  Icon(Icons.alt_route_outlined, color: kPrimaryColor),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  String getAddress(LockerDetailState state) {
    if (state.locker == null) {
      return "Loading...";
    } else {
      return state.locker.streetName +
          " " +
          state.locker.streetNumber +
          ", " +
          state.locker.postcode +
          " " +
          state.locker.city;
    }
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  BitmapDescriptor flexboxMarker;

  @override
  void initState() {
    getMarker();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LockerDetailCubit, LockerDetailState>(
        builder: (context, state) {
      if (state.locker == null) {
        return Container(
          height: 200,
          width: double.infinity,
          child: Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
              height: 30.0,
              width: 30.0,
            ),
          ),
        );
      }
      return Container(
        height: 200,
        width: double.infinity,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(state.locker.latitude, state.locker.longitude),
            zoom: 10.4746,
          ),
          //circles: circles,
          markers: getMarkers(state.locker.latitude, state.locker.longitude),
          rotateGesturesEnabled: false,
        ),
      );
    });
  }

  HashSet<Marker> getMarkers(double lat, double long) {
    HashSet<Marker> markers = HashSet<Marker>();
    if(flexboxMarker==null) {
      return markers;
    }
    Marker marker = Marker(
        markerId: MarkerId("chosenPosition"),
        position: LatLng(lat, long),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: flexboxMarker);
    markers.add(marker);
    return markers;
  }

  void getMarker() async {
    flexboxMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/flexbox_marker.png');
    setState(() {});
  }
}

class DefaultViewMenuBar extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;
  final List<String> favoriteIds;

  const DefaultViewMenuBar(
      {Key key, this.booking, this.cubit, this.favoriteIds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 30)),
        ),
        Expanded(
          child: Center(
            child: Text(
              booking.state == "COLLECTED"
                  ? "abgeholt"
                  : booking.state == "BOOKING_CREATED"
                      ? "gebucht"
                      : booking.state == "NOT_COLLECTED"
                          ? "eingelagert"
                          : "abgebrochen",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // FontWeight.w500, color: Colors.grey
            ),
          ),
          flex: 2,
        ),
        !(booking is BookingFrom)
            ? Expanded(
                child: IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      cubit.showShare(favoriteIds);
                    }))
            : Spacer(),
      ],
    );
  }
}