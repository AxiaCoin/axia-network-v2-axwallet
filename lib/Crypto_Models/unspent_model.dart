class Unspent {
  Unspent({
    this.success,
    this.message,
    this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory Unspent.fromJson(Map<String, dynamic> json) => Unspent(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data!.toJson(),
      };
}

class Data {
  Data({
    this.total,
    this.list,
  });

  final int? total;
  final List? list;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        total: json["total"],
        list: List<ListElement>.from(
            json["list"].map((x) => ListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "list": List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class ListElement {
  ListElement({
    this.address,
    this.block,
    this.txid,
    this.index,
    this.pkscript,
    this.value,
  });

  final String? address;
  final Block? block;
  final String? txid;
  final int? index;
  final String? pkscript;
  final int? value;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        address: json["address"],
        block: Block.fromJson(json["block"]),
        txid: json["txid"],
        index: json["index"],
        pkscript: json["pkscript"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "block": block!.toJson(),
        "txid": txid,
        "index": index,
        "pkscript": pkscript,
        "value": value,
      };
}

class Block {
  Block({
    this.height,
    this.position,
  });

  final int? height;
  final int? position;

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        height: json["height"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "height": height,
        "position": position,
      };
}
