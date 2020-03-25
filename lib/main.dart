import 'dart:io';

import 'package:flutter/material.dart';

import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/google_pay_constants.dart'
    as google_pay_constants;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Flutter Square In App Payments'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CardDetails> listOfCards = [];
  bool _googlePayEnabled = false;

  void _addPayment() async {
    await InAppPayments.setSquareApplicationId('sq0idp-3Y1mbGd1i8ASm9YB34F__w');

    bool canUseGooglePay = false;

    if (Platform.isAndroid) {
      await InAppPayments.initializeGooglePay(
        'CRQ810FK24DA6',
        google_pay_constants.environmentTest,
      );

      canUseGooglePay = await InAppPayments.canUseGooglePay;
    }

    setState(() {
      print(canUseGooglePay);
      _googlePayEnabled = canUseGooglePay;
    });
    InAppPayments.startCardEntryFlow(
      collectPostalCode: false,
      onCardNonceRequestSuccess: _onCardNonceRequestSuccess,
      onCardEntryCancel: _onCardEntryCancel,
    );
  }

  void _onCardNonceRequestSuccess(CardDetails cardDetails) {
    print(cardDetails.nonce);
    setState(() {
      listOfCards.add(cardDetails);
    });
    InAppPayments.completeCardEntry(
      onCardEntryComplete: _onCardEntryComplete,
    );
  }

  void _onCardEntryComplete() async {
    //Success

    _onStartGooglePay();
  }

  void _onStartGooglePay() async {
    try {
      await InAppPayments.requestGooglePayNonce(
        priceStatus: google_pay_constants.totalPriceStatusFinal,
        price: '1.00',
        currencyCode: 'EGP',
        onGooglePayNonceRequestSuccess: _onGooglePayNonceRequestSuccess,
        onGooglePayNonceRequestFailure: _onGooglePayNonceRequestFailure,
        onGooglePayCanceled: _onGooglePayCancel,
      );
    } on InAppPaymentsException catch (ex) {
      // handle the failure of starting apple pay
    }
  }

  /**
  * Callback when successfully get the card nonce details for processig
  * google pay sheet has been closed when this callback is invoked
  */
  void _onGooglePayNonceRequestSuccess(CardDetails result) async {
    try {
      // take payment with the card nonce details
      // you can take a charge
      // await chargeCard(result);

    } on Exception catch (ex) {
      // handle card nonce processing failure
    }
  }

  /**
  * Callback when google pay is canceled
  * google pay sheet has been closed when this callback is invoked
  */
  void _onGooglePayCancel() {
    // handle google pay canceled
  }

  /**
  * Callback when failed to get the card nonce
  * google pay sheet has been closed when this callback is invoked
  */
  void _onGooglePayNonceRequestFailure(ErrorInfo errorInfo) {
    // handle google pay failure
  }

  void _onCardEntryCancel() {
    //Cancel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: listOfCards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Add Payment Card..',
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: listOfCards.length,
              itemBuilder: (ctx, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      onTap: () {},
                      leading: Icon(
                        Icons.payment,
                        color: Colors.black,
                        size: 30.0,
                      ),
                      title: Text(
                        '**** **** **** ${listOfCards[index].card.lastFourDigits}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      subtitle: Text(
                        listOfCards[index].card.brand.toString().toUpperCase(),
                      ),
                    ),
                    Divider(
                      color: Colors.black45,
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPayment,
        tooltip: 'Add Payment',
        child: Icon(Icons.payment),
      ),
    );
  }
}
