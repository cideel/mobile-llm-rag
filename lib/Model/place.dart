class PlaceModel {
  final String id;
  final String title;
  final String address;
  final String imageUrl;
  final int like;
  final int comments;
  final double rating;
  final double distanceKm;
  final String openHour;
  final String socialMedia;
  final int uptrend;
  final String noPhone;
  final String ticketPrice;
  final String category;
  final String description;
  final String mapUrl;

  PlaceModel({
    required this.id,
    required this.title,
    required this.address,
    required this.imageUrl,
    required this.like,
    required this.comments,
    required this.rating,
    required this.distanceKm,
    required this.openHour,
    required this.socialMedia,
    required this.uptrend,
    required this.noPhone,
    required this.ticketPrice,
    required this.category,
    required this.description,
    required this.mapUrl
  });

  factory PlaceModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return PlaceModel(
      id: id,
      title: map['title'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['imgUrl'] ?? '',
      like: map['like'] ?? 0,
      comments: map['comments'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      openHour: map['openHour'] ?? '',
      socialMedia: map['socialMedia'] ?? '',
      uptrend: map['uptrend'] ?? 0,
      noPhone: map['noPhone'] ?? '',
      ticketPrice: map['tiketPrice'] ?? '',
      category: map['category']??'',
      description: map['description']??'',
      mapUrl: map['mapUrl']??''
    );
  }

 Map<String, dynamic> toJson() {
  return {
    'title': title,
    'address': address,
    'imgUrl': imageUrl, // <- harus sama dengan 'imgUrl' di fromMap
    'like': like,
    'comments': comments,
    'rating': rating,
    'distanceKm': distanceKm,
    'openHour': openHour,
    'socialMedia': socialMedia,
    'uptrend': uptrend,
    'noPhone': noPhone,
    'tiketPrice': ticketPrice,
    'category':category,// <- harus sama dengan 'tiketPrice' di fromMap
    'description':description,
    'mapUrl':mapUrl
  };
}


  PlaceModel copyWith({
    String? id,
    String? title,
    String? address,
    String? imageUrl,
    int? like,
    int? comments,
    double? rating,
    double? distanceKm,
    String? openHour,
    String? socialMedia,
    int? uptrend,
    String? noPhone,
    String? ticketPrice,
    String? category,
    String? description,
    String? mapUrl
  }) {
    return PlaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      like: like ?? this.like,
      comments: comments ?? this.comments,
      rating: rating ?? this.rating,
      distanceKm: distanceKm ?? this.distanceKm,
      openHour: openHour ?? this.openHour,
      socialMedia: socialMedia ?? this.socialMedia,
      uptrend: uptrend ?? this.uptrend,
      noPhone: noPhone ?? this.noPhone,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      category: category?? this.category,
      description: description?? this.description,
      mapUrl: mapUrl?? this.mapUrl
    );
  }

}
