import 'dart:convert';
import 'dart:typed_data';

import 'package:arbor/api/responses/record_response.dart';
import 'package:arbor/api/responses/records_response.dart';
import 'package:arbor/api/responses/transaction_response.dart';
import 'package:arbor/api/services/connectivity_service.dart';
import 'package:arbor/bls/ec.dart';
import 'package:arbor/bls/schemes.dart';
import 'package:arbor/clvm/program.dart';
import 'package:arbor/core/constants/hive_constants.dart';
import 'package:arbor/core/utils/local_signer.dart';
import 'package:arbor/models/transaction.dart';
import 'package:bech32m/bech32m.dart';
import 'package:flutter/cupertino.dart';
import 'package:hex/hex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '/models/models.dart';
import '../responses.dart';
import 'api_service.dart';

class WalletService extends ApiService {
  WalletService({this.baseURL = ApiService.baseURL});

  final String baseURL;
  Box blockchainBox = Hive.box(HiveConstants.blockchainBox);

  final _connectivityService = ConnectivityService();

  Future<dynamic> createNewWallet() async {
    String mnemonic = "";
    WalletKeysAndAddress? walletKeysAndAddress;

    try {
      mnemonic = LocalSigner.generateWalletMnemonic();
      walletKeysAndAddress =
          LocalSigner.convertMnemonicToKeysAndAddress(mnemonic);
    } on Exception catch (e) {
      throw Exception('ERROR : ${e.toString()}');
    }

    bool hasInternet = await _connectivityService.hasInternetConnection();

    if (hasInternet) {
      try {
        Blockchain? blockchain = await fetchBlockchainInfo();

        if (blockchainBox.containsKey(HiveConstants.blockchainData)) {
          blockchainBox.delete(HiveConstants.blockchainData);
          blockchainBox.put(HiveConstants.blockchainData, blockchain);
        }

        Wallet wallet = Wallet(
          name: '',
          privateKey: const HexEncoder()
              .convert(walletKeysAndAddress.privateKey.toBytes()),
          publicKey: const HexEncoder()
              .convert(walletKeysAndAddress.publicKey.toBytes()),
          address: walletKeysAndAddress.address,
          blockchain: Blockchain(
              name: blockchain.name,
              ticker: blockchain.ticker,
              unit: blockchain.unit,
              precision: blockchain.precision,
              logo: blockchain.logo,
              network_fee: blockchain.network_fee,
              agg_sig_me_extra_data: blockchain.agg_sig_me_extra_data),
          balance: 0,
        );

        return [wallet, mnemonic];
      } on Exception catch (e) {
        throw Exception('ERROR : ${e.toString()}');
      }
    } else {
      Blockchain? blockchain;
      try {
        blockchain = blockchainBox.get(HiveConstants.blockchainData,
            defaultValue: HiveConstants.defaultBlockchainData);

        debugPrint("${blockchain!.unit}  ${blockchain.name}");
      } on Exception catch (e) {
        throw Exception('ERROR : ${e.toString()}');
      }

      Wallet wallet = Wallet(
        name: '',
        privateKey: const HexEncoder()
            .convert(walletKeysAndAddress.privateKey.toBytes()),
        publicKey: const HexEncoder()
            .convert(walletKeysAndAddress.publicKey.toBytes()),
        address: walletKeysAndAddress.address,
        blockchain: Blockchain(
            name: blockchain.name,
            ticker: blockchain.ticker,
            unit: blockchain.unit,
            precision: blockchain.precision,
            logo: blockchain.logo,
            network_fee: blockchain.network_fee,
            agg_sig_me_extra_data: blockchain.agg_sig_me_extra_data),
        balance: 0,
      );

      return [wallet, mnemonic];
    }
  }

  // @POST("/v2/blockchain")
  Future<Blockchain> fetchBlockchainInfo() async {
    try {
      final blockchainResponse = await http.post(
        Uri.parse('$baseURL/v2/blockchain'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'blockchain': 'xch',
        }),
      );

      if (blockchainResponse.statusCode == 200) {
        BlockchainResponse blockchainResponseModel =
            BlockchainResponse.fromJson(jsonDecode(blockchainResponse.body));

        Blockchain blockchain = Blockchain(
          name: blockchainResponseModel.blockchainData.name,
          ticker: blockchainResponseModel.blockchainData.ticker,
          unit: blockchainResponseModel.blockchainData.unit,
          precision: blockchainResponseModel.blockchainData.precision,
          logo: blockchainResponseModel.blockchainData.logo,
          network_fee: blockchainResponseModel.blockchainData.blockchainFee,
          agg_sig_me_extra_data:
              blockchainResponseModel.blockchainData.aggSigMeExtraData,
        );

        return blockchain;
      } else {
        throw Exception(blockchainResponse.body);
      }
    } on Exception catch (e) {
      throw Exception('ERROR : ${e.toString()}');
    }
  }

  Future<Wallet> recoverWallet(String phrase) async {
    WalletKeysAndAddress? walletKeysAndAddress;

    try {
      walletKeysAndAddress =
          LocalSigner.convertMnemonicToKeysAndAddress(phrase);
    } on Exception catch (e) {
      throw Exception('ERROR : ${e.toString()}');
    }

    try {
      Blockchain? blockchain = await fetchBlockchainInfo();
      final balanceResponse = await http.post(
        Uri.parse('$baseURL/v2/balance'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'address': walletKeysAndAddress.address,
        }),
      );

      if (balanceResponse.statusCode == 200) {
        BalanceResponse balance =
            BalanceResponse.fromJson(jsonDecode(balanceResponse.body));

        Wallet wallet = Wallet(
          name: '',
          privateKey: const HexEncoder()
              .convert(walletKeysAndAddress.privateKey.toBytes()),
          publicKey: const HexEncoder()
              .convert(walletKeysAndAddress.publicKey.toBytes()),
          address: walletKeysAndAddress.address,
          blockchain: Blockchain(
            name: blockchain.name,
            ticker: blockchain.ticker,
            unit: blockchain.unit,
            precision: blockchain.precision,
            logo: blockchain.logo,
            network_fee: blockchain.network_fee,
            agg_sig_me_extra_data: blockchain.agg_sig_me_extra_data,
          ),
          balance: balance.balance,
        );

        return wallet;
      } else {
        throw Exception(balanceResponse.body);
      }
    } on Exception catch (e) {
      throw Exception('ERROR : ${e.toString()}');
    }
  }

  // @POST("/v2/balance")
  Future<int> fetchWalletBalance(String walletAddress) async {
    try {
      final balanceData = await http.post(
        Uri.parse('$baseURL/v2/balance'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'address': walletAddress,
        }),
      );

      if (balanceData.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        BalanceResponse balanceResponse =
            BalanceResponse.fromJson(jsonDecode(balanceData.body));

        return balanceResponse.balance;
      } else {
        // If the server did not return a 200 OK response,
        var baseResponse = BaseResponse.fromJson(jsonDecode(balanceData.body));
        throw Exception('ERROR: ${baseResponse.error}.');
      }
    } on Exception catch (e) {
      throw Exception('${e.toString()}.');
    }
  }

  // @GET("/v2/transactions")
  Future<TransactionsGroup> fetchWalletTransactions(
      String walletAddress) async {
    try {
      final transactionsData = await http.post(
        Uri.parse('$baseURL/v2/transactions'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'address': walletAddress,
        }),
      );

      if (transactionsData.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        TransactionListResponse transactionListResponse =
            TransactionListResponse.fromJson(jsonDecode(transactionsData.body));

        List<Transaction> transactionsList = [];
        for (TransactionGroupResponse transactions
            in transactionListResponse.transactions) {
          for (TransactionsResponse t in transactions.transactions) {
            Transaction transaction = Transaction(
                type: transactions.type,
                timestamp: transactions.timestamp,
                block: transactions.block,
                address: ((t.sender != null) ? t.sender! : t.destination!),
                amount: t.amount,
                fee: transactions.fee,
                baseAddress: walletAddress);
            transactionsList.add(transaction);
          }
        }
        return TransactionsGroup(
            address: walletAddress, transactionsList: transactionsList);
      } else {
        throw Exception(transactionsData.body);
      }
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> sendXCH(
      {required String privateKey,
      required String address,
      required int amount,
      required int fee,
      required String ticker,
      required String aggSigMeExtraData}) async {
    SignedTransactionResponse? signedTransactionResponse;
    var totalAmount = amount + fee;

    try {
      signedTransactionResponse =
          await LocalSigner.usePrivateKeyToGenerateHash(privateKey);
    } on Exception catch (e) {
      throw Exception('ERROR : ${e.toString()}');
    }

    try {
      final responseData = await http.post(Uri.parse('$baseURL/v2/records'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'address': signedTransactionResponse.address,
          }));
      if (responseData.statusCode == 200) {
        RecordsResponse recordsResponse =
            RecordsResponse.fromJson(jsonDecode(responseData.body));
        var records = recordsResponse.records;
        records.sort((a, b) => b.coin.amount - a.coin.amount);
        List<RecordResponse> spendRecords = [];
        var spendAmount = 0;
        calculator:
        while (records.isNotEmpty && spendAmount < totalAmount) {
          for (var i = 0; i < records.length; i++) {
            if (spendAmount + records[i].coin.amount <= totalAmount) {
              var record = records.removeAt(i--);
              spendRecords.add(record);
              spendAmount += record.coin.amount;
              continue calculator;
            }
          }
          var record = records.removeAt(0);
          spendRecords.add(record);
          spendAmount += record.coin.amount;
        }

        if (spendAmount < totalAmount) {
          return 'Insufficient funds.';
        }
        var change = spendAmount - amount - fee;
        List<JacobianPoint> signatures = [];
        List<Map<String, dynamic>> spends = [];
        var target = true;
        var destinationHash = segwit.decode(address).program;

        for (var record in spendRecords) {
          var conditions = Program.list(target
              ? [
                    Program.list([
                      Program.int(51),
                      Program.atom(Uint8List.fromList(destinationHash)),
                      Program.int(amount)
                    ])
                  ] +
                  (change > 0
                      ? [
                          Program.list([
                            Program.int(51),
                            Program.atom(signedTransactionResponse.puzzleHash),
                            Program.int(change)
                          ])
                        ]
                      : [])
              : []);
          var solution = Program.list([conditions]);
          target = false;
          var coinId = Program.list([
            Program.int(11),
            Program.cons(Program.int(1),
                Program.hex(record.coin.parentCoinInfo.substring(2))),
            Program.cons(Program.int(1),
                Program.hex(record.coin.puzzleHash.substring(2))),
            Program.cons(Program.int(1), Program.int(record.coin.amount))
          ]).run(Program.nil()).program.atom;
          signatures.add(AugSchemeMPL.sign(
              signedTransactionResponse.privateKeyObject,
              Uint8List.fromList(conditions.hash() +
                  coinId +
                  const HexDecoder().convert(aggSigMeExtraData))));
          spends.add({
            'coin': record.coin.toJson(),
            'puzzle_reveal': const HexEncoder()
                .convert(signedTransactionResponse.wallet.serialize()),
            'solution': const HexEncoder().convert(solution.serialize())
          });
        }
        var aggregate = AugSchemeMPL.aggregate(signatures);
        try {
          final responseData =
              await http.post(Uri.parse('$baseURL/v2/transaction'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'spend_bundle': {
                      'coin_spends': spends,
                      'aggregated_signature':
                          const HexEncoder().convert(aggregate.toBytes())
                    },
                    'blockchain': ticker.toLowerCase()
                  }));
          if (responseData.statusCode == 200) {
            return 'success';
          } else {
            return responseData.body;
          }
        } on Exception catch (e) {
          return e.toString();
        }
      } else {
        return responseData.body;
      }
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
