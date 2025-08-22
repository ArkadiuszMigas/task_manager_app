import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  // Sprawdza, czy usługa lokalizacji jest włączona i czy aplikacja ma odpowiednie uprawnienia.
  Future<bool> _ensureServiceAndPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Sprawdza uprawnienia do lokalizacji.
    // Jeśli uprawnienia są odrzucone, prosi o nie.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Uprawnienia są trwale odrzucone, nie można ich prosić ponownie.
      return false;
    }
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final bool ok = await _ensureServiceAndPermission();
    if (!ok) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 5),
      );
    } on TimeoutException {
      // fallback – ostatnia znaną lokację
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;

      //ponowienie z niższą dokładnością i dłuższym limitem czasu
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        return null;
      }
    } catch (_) {
      // inne błędy związane z lokalizacją
      final Position? last = await Geolocator.getLastKnownPosition();
      return last;
    }
  }
}
