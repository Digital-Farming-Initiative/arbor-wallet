import 'package:arbor/api/services/wallet_service.dart';
import 'package:arbor/core/constants/ui_constants.dart';
import 'package:arbor/core/enums/status.dart';
import 'package:arbor/core/utils/regex.dart';
import 'package:arbor/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SendCryptoProvider extends ChangeNotifier {
  Status sendCryptoStatus = Status.IDLE;

  Status _walletBalanceStatus = Status.IDLE;
  Status get walletBalanceStatus => _walletBalanceStatus;

  final walletService = WalletService();

  Blockchain? blockchain;

  String _appBarTitle = '';
  String get appBarTitle => _appBarTitle;

  String _receiverAddress = '';
  String get receiverAddress => _receiverAddress;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _addressErrorMessage = '';
  String get addressErrorMessage => _addressErrorMessage;

  var transactionResponse;

  int _autoRefreshBalanceTimer = 90;
  int get autoRefreshBalanceTimer => _autoRefreshBalanceTimer;
  int forkPrecision = 0;
  int networkFee = 0;
  String forkName = '';
  String forkTicker = '';
  String privateKey = '';
  String currentUserAddress = '';
  String aggSigExtraData = '';

  int _walletBalance = 0;
  int get walletBalance => _walletBalance;

  String _transactionValue = '0';
  String get transactionValue => _transactionValue;

  String _transactionValueForDisplay = '0';
  String get transactionValueForDisplay => _transactionValueForDisplay;

  bool get enableButton => _validAddress && double.parse(_transactionValue) > 0;

  double get convertedBalance => _walletBalance / chiaPrecision;
  String get readableBalance => convertedBalance.toStringAsFixed(forkPrecision);

  double _amount = 0;
  double get amount => _amount;

  bool transactionInProgress = false;

  bool scannedData = false;
  bool _validAddress = false;

  bool _sendButtonIsBusy = false;
  bool get sendButtonIsBusy => _sendButtonIsBusy;

  bool validAddress(String address) {
    // format and length are from
    // https://github.com/Chia-Network/chia-blockchain/blob/main/chia/util/bech32m.py
    // https://github.com/sipa/bips/blob/bip-taproot/bip-0136.mediawiki
    int _maxPossibleLength = forkTicker.length + 1 + 58;
    _validAddress = address.startsWith('${forkTicker}1') &&
        Regex.chiaAddressRegex.hasMatch(_receiverAddress) &&
        address.length == _maxPossibleLength;

    //Print to console only in debug mode
    debugPrint('Address is valid $_validAddress');
    notifyListeners();
    return _validAddress;
  }

  getClipBoardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      setReceiverAddress(data.text!);
    } else {
      _addressErrorMessage = 'Clipboard is empty';
      notifyListeners();
    }
  }

  setWalletBalance(int v) {
    _walletBalance = v;
    notifyListeners();
  }

  setTransactionValue(v) {
    if (_transactionValue == '0' && v != '.') {
      _transactionValue = v;
      notifyListeners();
      return;
    }

    if (_transactionValue == '0' && v == '.') {
      _transactionValue = '0.';
      notifyListeners();
      return;
    }

    if (_transactionValue.contains('.') && v == '.') {
      return;
    }

    if (_transactionValue.contains('.') &&
        _transactionValue.split('.').last.length == forkPrecision) {
      return;
    }

    _transactionValue += v;
    notifyListeners();
  }

  deleteCharacter() {
    if (_transactionValue == '0') {
    } else if (_transactionValue != '0' && _transactionValue.length == 1) {
      _transactionValue = '0';
    } else {
      _transactionValue = removeLastCharacter(_transactionValue);
    }
    notifyListeners();
  }

  useMax() {
    _transactionValue = readableBalance;
    notifyListeners();
  }

  setReceiverAddress(
    String value,
  ) {
    _receiverAddress = value;
    if (value.length >= 1) {
      bool addressIsValid = validAddress(value);
      if (addressIsValid) {
        _addressErrorMessage = '';
      } else {
        _receiverAddress = '';
        _addressErrorMessage = 'Invalid address';
      }
    } else {
      _addressErrorMessage = '';
      _validAddress = false;
    }
    notifyListeners();
  }

  void authoriseTransaction() async {
    sendCryptoStatus = Status.LOADING;
    _appBarTitle = 'Sending';
    notifyListeners();
    await send();
  }

  getTransactionFee() async {
    _errorMessage="";
    _sendButtonIsBusy = true;
    sendCryptoStatus = Status.IDLE;
    notifyListeners();
    try {
      blockchain = await walletService.fetchBlockchainInfo();
      networkFee = blockchain!.network_fee;
      aggSigExtraData = blockchain!.agg_sig_me_extra_data;
      _sendButtonIsBusy = false;
      notifyListeners();
    } on Exception catch (e) {
      _errorMessage = e.toString();
      _sendButtonIsBusy = false;
      sendCryptoStatus = Status.ERROR;
      notifyListeners();
    }
  }

  send() async {
    sendCryptoStatus = Status.LOADING;
    notifyListeners();
    try {
      _transactionValueForDisplay = _transactionValue;
      transactionResponse = await walletService.sendXCH(
          privateKey: privateKey,
          amount: (double.parse(_transactionValue) * chiaPrecision).toInt(),
          address: _receiverAddress,
          fee: blockchain!.network_fee,
          ticker: blockchain!.ticker,
          aggSigMeExtraData: aggSigExtraData);

      if (transactionResponse == 'success') {
        transactionInProgress = true;
        sendCryptoStatus = Status.SUCCESS;
        _walletBalanceStatus = Status.IDLE;
        _transactionValue = '0';
        _receiverAddress = '';
        _appBarTitle = 'All Done';
      } else {
        transactionInProgress = false;
        _errorMessage = transactionResponse;
        sendCryptoStatus = Status.ERROR;
      }
      notifyListeners();
    } on Exception catch (e) {
      transactionInProgress = false;
      _errorMessage = e.toString();
      sendCryptoStatus = Status.ERROR;
      notifyListeners();
    }
  }

  getBalance() async {
    _walletBalanceStatus = Status.LOADING;
    notifyListeners();
    try {
      _walletBalance =
          await walletService.fetchWalletBalance(currentUserAddress);
      _walletBalanceStatus = Status.SUCCESS;
      notifyListeners();
    } on Exception catch (e) {
      _walletBalance = 0;
      _walletBalanceStatus = Status.ERROR;
      notifyListeners();
      throw Exception('${e.toString()}');
    }
  }

  clearInput() {
    _transactionValue = '0';
    _transactionValueForDisplay = '0';
    _receiverAddress = '';
    _errorMessage = '';
    _addressErrorMessage = '';
    notifyListeners();
  }

  clearStatus() {
    _validAddress = false;
    sendCryptoStatus = Status.IDLE;
  }

  close() {
    sendCryptoStatus = Status.IDLE;
    notifyListeners();
  }

  String removeLastCharacter(String str) {
    if (str.length > 1) {
      str = str.substring(0, str.length - 1);
    } else {
      str = '0';
    }
    return str;
  }

  void onAddressQRCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      _receiverAddress = scanData.code;
      scannedData = true;
      notifyListeners();
    });
  }

  Future<Box> refreshWalletBalances(Box walletBox) async {
    for (int index = 0; index < walletBox.length; index++) {
      Wallet existingWallet = walletBox.getAt(index);
      int newBalance =
      await walletService.fetchWalletBalance(existingWallet.address);

      Wallet newWallet = Wallet(
        name: existingWallet.name,
        privateKey: existingWallet.privateKey,
        publicKey: existingWallet.publicKey,
        address: existingWallet.address,
        balance: newBalance,
        blockchain: existingWallet.blockchain,
      );

      walletBox.putAt(index, newWallet);
    }
    transactionInProgress = false;
    notifyListeners();
    debugPrint("From view model - done");
    return walletBox;
  }

  String feeForDisplay() {
    return Wallet.amountToDisplayWithPrecision(networkFee, blockchain!.precision);
  }
}
