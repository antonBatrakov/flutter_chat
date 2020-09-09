import 'package:chopper/chopper.dart';
import 'package:flutter_chat/api/model/post.dart';

import 'converter/model_converters.dart';

part 'info_api.chopper.dart';

@ChopperApi()
abstract class InfoService extends ChopperService {
  @Get(path: "posts/{id}")
  Future<Response<PostModel>> getInfo(@Path("id") int id);

  static InfoService create() {
    final client = ChopperClient(
      baseUrl: 'https://jsonplaceholder.typicode.com/',
      converter: ModelConverter(),
      errorConverter: JsonConverter(),
      services: [
        _$InfoService(),
      ],
    );
    return _$InfoService(client);
  }
}
