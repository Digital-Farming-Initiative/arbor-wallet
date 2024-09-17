import 'package:arbor/models/blockchain.dart';

class HiveConstants {
  static const String hiveEncryptionKeyKey = 'arbor_hive_key';
  static const String hiveEncryptionSchemaKey = 'arbor_hive_version_key';
  static const String blockchainData = 'blockchainData';

  // Adding or removing boxes requires deleting them in no_encryption_available_screen.dart

  static const String blockchainBox = 'blockchainBox';
  static const String transactionsBox = 'transactionsBox';
  static const String walletBox = 'walletBox';

  static Blockchain defaultBlockchainData = Blockchain(
    name: "Chia",
    ticker: "xch",
    unit: "Mojo",
    precision: 12,
    logo: "/icons/blockchains/chia.png",
    network_fee: 0,
    agg_sig_me_extra_data:
        "ccd5bb71183532bff220ba46c268991a3ff07eb358e8255a65c30a2dce0e5fbb",
  );
}
