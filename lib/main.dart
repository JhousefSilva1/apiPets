import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final apiEndpointProvider =
    Provider<String>((ref) => 'https://dog.ceo/api/breeds/image/random');

final dogImageProvider = FutureProvider.autoDispose<String>((ref) async {
  final client = ref.watch(httpClientProvider);
  final apiEndpoint = ref.watch(apiEndpointProvider);
  final response = await client.get(Uri.parse(apiEndpoint));
  final data = json.decode(response.body);
  return data['message'];
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DogImageWidget(),
      title: 'Buscador de Mascotas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class DogImageWidget extends ConsumerWidget {
  const DogImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogImageAsyncValue = ref.watch(dogImageProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Buscador de Mascotas')),
      ),
      body: Center(
        child: dogImageAsyncValue.when(
          data: (dogImage) => SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FadeInImage(
              image: NetworkImage(dogImage),
              placeholder: const AssetImage('assets/loader.gif'),
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return const FadeInImage(
                    placeholder: AssetImage('assets/loader.gif'),
                    image: NetworkImage(
                        'https://previews.123rf.com/images/kaymosk/kaymosk1804/kaymosk180400006/100130939-error-404-page-not-found-error-with-glitch-effect-on-screen-vector-illustration-for-your-design.jpg'),
                    fit: BoxFit.cover);
              },
            ),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
      floatingActionButton: ElevatedButton(
        //texto
        style: ButtonStyle(
          //espacio
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),

          //espacio despues de la imagne

          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          )),
          backgroundColor: MaterialStateProperty.all<Color>(
              Color.fromARGB(255, 33, 177, 243)),
        ),
        child: const Text('Generar nueva Imagen'),
        onPressed: () => ref.refresh(dogImageProvider),
      ),
    );
  }
}
