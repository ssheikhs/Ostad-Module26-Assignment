
import 'package:flutter/material.dart';

import 'features/home/pages/home_page.dart';

class LibraryFinderApp extends StatelessWidget {
  const LibraryFinderApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Finder',
      theme: ThemeData(
       
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}
