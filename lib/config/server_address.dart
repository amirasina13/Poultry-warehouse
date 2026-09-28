class ServerAddresses {
  // Log in
  static const login = '/auth';

  // Master File
  static const category = '/inventory/categories';
  static const handheldLocation = '/handheld-location';
  static const area = '/handheld-area';
  static const vendor = '/vendors';
  static const client = '/client';
  static const rack = '/racks';
  static const tray = '/tray';
  static const reasonCode = '/reason-code';
  static const inventoryList = '/inventory/inventories';
  static const stockBalance = '/warehouse/stock-balance/get';

  // Picking list
  static const getPickingList = '/picking-list';
  static const getPickingListDetails = '/picking-list/details';

  // GIN Document
  static const getDocumentNoList = '/warehouse/transfer-transaction/get-out';
  static const getDocumentNoDetails =
      '/warehouse/transfer-transaction/get-out/details';

  // Transaction
  static const createTransaction = '/warehouse/transfer-transaction/create';
  static const getTransactionStatus = '/warehouse/transfer-transaction/status';

  // Upload
  static const jobUpload = '/warehouse/transfer-transaction/upload';
}
