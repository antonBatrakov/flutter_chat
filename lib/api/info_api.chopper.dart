// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$InfoService extends InfoService {
  _$InfoService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = InfoService;

  @override
  Future<Response<PostModel>> getInfo(int id) {
    final $url = 'posts/$id';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<PostModel, PostModel>($request);
  }
}
