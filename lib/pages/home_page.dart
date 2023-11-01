import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running/components/drawer.dart';
import 'package:running/components/post_list.dart';
import 'package:running/pages/post_add_page.dart';
import 'package:running/pages/post_search_page.dart';
import 'package:running/pages/profile_page.dart';
import 'package:running/pages/qna_page.dart';
import 'package:running/utils/current_location.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isClick = true;
  GoogleMapController? _mapController;

  final CurrentLocation currentLocation = CurrentLocation();

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyProfilePage(),
      ),
    );
  }

  void communityPage() {}

  void qnaPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QnAPage(),
      ),
    );
  }

  void goToAddCrewPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyAddCrew(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await currentLocation.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("User")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                userData['userregion'],
                style: TextStyle(color: Colors.grey[850]),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[850]),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PostSearch()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
        onCommunity: communityPage,
        onQnA: qnaPage,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isClick = true;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "모집 중인 크루",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isClick ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2.0,
                        width: MediaQuery.of(context).size.width / 2 - 8,
                        color: isClick ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isClick = false;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "크루 지도",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: !isClick ? Colors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2.0,
                        width: MediaQuery.of(context).size.width / 2 - 8,
                        color: !isClick ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isClick)
            const Expanded(
              child: MyPostList(),
            ),
          if (!isClick)
            Expanded(
              child: FutureBuilder(
                future: _loadPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final posts = snapshot.data as List<Post>;
                    return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          currentLocation.currentPosition?.latitude ?? 0.0,
                          currentLocation.currentPosition?.longitude ?? 0.0,
                        ),
                        zoom: 15.0,
                      ),
                      markers: _createMarkers(posts),
                      myLocationEnabled: true,
                      mapToolbarEnabled: true,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    );
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: isClick
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyAddCrew()),
                );
              },
              elevation: 0.0,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<List<Post>> _loadPosts() async {
    // Firestore에서 게시글 데이터 가져오는 코드
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Posts').get();
    final posts = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Post(
        startLocation: data['startLocation'],
        startLocationText: data['crewName'],
      );
    }).toList();
    return posts;
  }

  Set<Marker> _createMarkers(List<Post> posts) {
    return posts.map((post) {
      return Marker(
        markerId: MarkerId(post.startLocationText),
        position:
            LatLng(post.startLocation.latitude, post.startLocation.longitude),
        infoWindow: InfoWindow(title: post.startLocationText),
      );
    }).toSet();
  }
}

class Post {
  // 시작위치와 시작 텍스트를 저장
  final GeoPoint startLocation;
  final String startLocationText;

  Post({required this.startLocation, required this.startLocationText});
}
