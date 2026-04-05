import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final appwriteClient = Client()
  ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT'] ?? '')
  ..setProject(dotenv.env['APPWRITE_PROJECT_ID'] ?? '');

final appwriteAccount = Account(appwriteClient);
final appwriteDatabases = Databases(appwriteClient);
final appwriteStorage = Storage(appwriteClient);
final appwriteFunctions = Functions(appwriteClient);
