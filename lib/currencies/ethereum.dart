import 'package:http/http.dart';
import 'package:wallet/code/constants.dart';
import 'package:wallet/code/currency.dart';
import 'package:wallet/code/models.dart';
import 'package:coinslib/coinslib.dart' as coinslib;
import 'package:wallet/code/services.dart';
import 'package:web3dart/web3dart.dart';

class Ethereum implements Currency {
  @override
  CoinData coinData = CoinData(
    name: "Ethereum",
    unit: "ETH",
    coinType: isTestNet ? 1 : 60,
    rate: 1,
    change: "1",
  );

  @override
  CryptoWallet getWallet() {
    coinslib.HDWallet hdWallet = services.hdWallet!;
    var wallet = hdWallet.derivePath("m/44'/${coinData.coinType}'/0'/0/0");
    var ethWallet = EthPrivateKey.fromHex("0x${wallet.privKey}");
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
    return CryptoWallet(
        address: ethWallet.address.hexEip55,
        privKey: "0x${wallet.privKey}",
        pubKey: "0x${wallet.pubKey}",
        keyPair: null);
  }

  @override
  getBalance(List address) {
    var ethWallet = EthPrivateKey.fromHex(getWallet().privKey);
    var client = Web3Client(
        "https://rinkeby.infura.io/v3/ed9107daad174d5d92cc1b16d27a0605",
        Client());
    client.getBalance(ethWallet.address).then((value) => print(value.getInWei));
  }

  @override
  getTransactions(String address) {
    throw UnimplementedError();
  }

  @override
  importWallet() {
    throw UnimplementedError();
  }
}
