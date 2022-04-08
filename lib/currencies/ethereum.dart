import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:coinslib/coinslib.dart' as coinslib;
import 'package:wallet/code/services.dart';
import 'package:wallet/widgets/common.dart';
import 'package:web3dart/web3dart.dart';

class Ethereum implements Currency {
  @override
  CoinData coinData = CoinData(
    name: "Ethereum",
    unit: "ETH",
    prefix: "0x",
    coinType: 60,
    rate: 1,
    change: "1",
    selected: true,
  );

  @override
  CryptoWallet getWallet() {
    coinslib.HDWallet hdWallet = services.hdWallet!;
    var wallet = hdWallet.derivePath("m/44'/${coinData.coinType}'/0'/0/0");
    var ethWallet =
        EthPrivateKey.fromHex("${coinData.prefix}${wallet.privKey}");
    // var client = Web3Client(
    //     "https://rinkeby.infura.io/v3/ed9107daad174d5d92cc1b16d27a0605",
    //     Client());
    // client.getGasPrice().then((value) => print(value.getInWei));
    // var signedData = await client.signTransaction(
    //   ethWallet,
    //   Transaction(
    //     to: EthereumAddress.fromHex(
    //         '0xF98863D856b1Dca7627E98CeA960BA40958774f6'),
    //     gasPrice: EtherAmount.inWei(BigInt.one),
    //     maxGas: 100000,
    //     value: EtherAmount.fromUnitAndValue(EtherUnit.szabo, BigInt.one),
    //   ),
    //   fetchChainIdFromNetworkId: true,
    //   chainId: null,
    // );
    // var sent = await client.sendRawTransaction(signedData);
    // print(sent);
    // var asd = await client.sendTransaction(
    //   ethWallet!,
    //   Transaction(
    //     to: EthereumAddress.fromHex(
    //         '0xF98863D856b1Dca7627E98CeA960BA40958774f6'),
    //     gasPrice: EtherAmount.inWei(BigInt.one),
    //     maxGas: 100000,
    //     value: EtherAmount.fromUnitAndValue(EtherUnit.szabo, BigInt.one),
    //   ),
    //   fetchChainIdFromNetworkId: true,
    //   chainId: null,
    // );
    // print(asd);
    // print(asd.getInWei);
    // print(asd.getInEther);
    // print(asd.getValueInUnit(EtherUnit.ether));
    // print(utf8.decode(asd));
    // coinData.address = ethWallet.address.hexEip55;
    // coinData.pubKey = "0x${wallet.pubKey}";
    // coinData.privKey = "0x${wallet.privKey}";
    // print(coinData.address);
    // print(coinData.privKey);
    // print(coinData.pubKey);
    // print(ethWallet.address.hexEip55);
    return CryptoWallet(
        address: ethWallet.address.hexEip55,
        privKey: "${coinData.prefix}${wallet.privKey}",
        pubKey: "${coinData.prefix}${wallet.pubKey}",
        keyPair: null);
  }

  @override
  getBalance(List address) async {
    // var ethWallet = EthPrivateKey.fromHex(getWallet().privKey);
    // var client = Web3Client(
    //     "https://rinkeby.infura.io/v3/ed9107daad174d5d92cc1b16d27a0605",
    //     Client());
    // return await client.getBalance(ethWallet.address);
    var amount =
        await APIServices().getBalance([getWallet().address], coinData.unit);
    double balance = amount["data"].first["confirmed"];
    // print(amount);
    // print("balance is ${balance.toStringAsFixed(6)} ${coinData.unit}");
    return balance;
  }

  @override
  getTransactions({required int offset, required int limit}) async {
    var response = await APIServices().getTransactions(
      getWallet().address,
      coinData.unit,
      offset: offset,
      limit: limit,
    );
    var data = response["data"]["list"];
    int total = response["data"]["total"];
    List<TransactionModel> transactions = [];
    // print("data is $data");
    data.forEach((e) {
      transactions.add(
        TransactionModel(
          from: e["from"],
          to: e["to"],
          amount: double.parse(e["value"]) / wei,
          time: DateTime.fromMillisecondsSinceEpoch(
              int.parse(e["timeStamp"]) * 1000),
          hash: e["hash"],
          fee: double.parse(e["gasUsed"]) * double.parse(e["gasPrice"]) / wei,
        ),
      );
    });
    // print(response);
    return [total, transactions];
  }

  @override
  sendTransaction(double amount, String receiverAddress) async {
    var ethWallet = EthPrivateKey.fromHex(getWallet().privKey);
    print("address is ${ethWallet.address.hexEip55}");
    var client = Web3Client(
        "https://rinkeby.infura.io/v3/ed9107daad174d5d92cc1b16d27a0605",
        Client());
    var gasPrice = await client.getGasPrice();
    var signedData = await client.signTransaction(
      ethWallet,
      Transaction(
        to: EthereumAddress.fromHex(receiverAddress),
        gasPrice: gasPrice,
        maxGas: 100000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.szabo, BigInt.one),
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );
    var hex = coinData.prefix + HexEncoder().convert(signedData);
    print("signed hex is $hex");
    Map body = {
      "network": network,
      "currency": coinData.unit,
      "fromAddress": getWallet().address,
      "toAddress": receiverAddress,
      "amount": amount,
      "signedRawTransaction": hex
    };
    var response = await APIServices().sendTransaction(body);
    print(response);
    return response;
  }
}
