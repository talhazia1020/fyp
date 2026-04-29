// class Areas {
//   late String location;


//   Areas({
//     required this.location,

//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'locations': location,
//     };
//   }

//   factory Areas.fromMap(Map<String, dynamic> map) {
//     return Areas(
//       location: map['location'],
//     );
//   }
// }




class Areas {
  late String location;

  Areas({
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'location': location, // FIX: was 'locations' (plural) — must match Firestore field
    };
  }

  factory Areas.fromMap(Map<String, dynamic> map) {
    return Areas(
      location: map['location'] ?? '', // FIX: added fallback so it never throws null error
    );
  }
}