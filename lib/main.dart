import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class Block {
  int index;
  DateTime timestamp;
  String data;
  String previousHash;
  String hash;
  int nonce;
  bool valid;

  Block(
      this.index, this.timestamp,
      this.data, this.previousHash,
      this.hash, this.nonce, this.valid
      );
}

class Blockchain {
  late List<Block> chain;
  late int difficulty;
  late int index;

  Blockchain() {
    index = 0;
    chain = [createGenesisBlock()];
    difficulty = 4;
  }

  Block createGenesisBlock() {
    DateTime timestamp = DateTime.now();
    return Block(
      index,
      timestamp,
      'Genesis Block',
      '0',
      calculateHash(0, timestamp, 'Genesis Block', '0', 0),
      0,
      true,
    );
  }

  String calculateHash(int index, DateTime timestamp,
      String data, String previousHash,
      int nonce)
  {
    String input = index.toString() +
        timestamp.toIso8601String() +
        jsonEncode(data) +
        previousHash +
        nonce.toString();
    List<int> bytes = utf8.encode(input);
    Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  Block mineBlock(Block block) {
    while (!block.hash.startsWith('0' * difficulty)) {
      block.nonce++;
      block.hash = calculateHash(block.index,
          block.timestamp, block.data,
          block.previousHash, block.nonce);
    }
    block.valid = true;
    return block;
  }

  void addBlock(String data) {
    Block previousBlock = chain[chain.length - 1];
    int index = previousBlock.index + 1;

    DateTime timestamp = DateTime.now();
    int nonce = 0;
    String hash = calculateHash(index, timestamp, data, previousBlock.hash, nonce);
    Block newBlock = Block(index, timestamp, data, previousBlock.hash, hash, nonce, true);
    newBlock = mineBlock(newBlock);
    chain.add(newBlock); // Add the new block to the chain
  }

  List<Block> getBlocks() {
    return List<Block>.from(chain); // Create a copy of the chain list
  }

  void invalidateBlock(Block block) {
    chain[block.index].data = block.data;
    for (int i = block.index; i < chain.length; i++) {
      chain[i].valid = false;
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final blockchain = Blockchain();
  final TextEditingController _dataController = TextEditingController();

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Blockchain Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blockchain Demo'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _dataController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter block data here',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if(!(_dataController.text.length == 0))
                    setState(() {
                      blockchain.addBlock(_dataController.text);
                      _dataController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey, // Set the button background color
                    onPrimary: Colors.white, // Set the text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Set the button border radius
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Set the button padding
                    elevation: 3, // Set the button elevation
                  ),
                  child: Text(
                    'Add Block',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // Set the text style
                  ),
                )
,
                SizedBox(height: 16),
                Text(
                  'Blockchain:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: blockchain.getBlocks().length,
                  itemBuilder: (context, index) {
                    Block block = blockchain.getBlocks()[index];
                    TextEditingController _blockDataController = TextEditingController(text: block.data); // Create a TextEditingController for each block

                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _blockDataController,
                              onChanged: (value) {
                                block.data = value; // Update the data of the block when the text field changes
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter block data',
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      blockchain.invalidateBlock(block); // Invalidate the block
                                    });
                                  },
                                  child: Text('save'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      blockchain.mineBlock(block); // Mine the block
                                    });
                                  },
                                  child: Text('Mine'),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(children: [Text("the hash :"),Container(width: 250.0,child: Text(block.hash),)]),
                            SizedBox(height: 8),
                            Row(children: [Text("the previous hash :"),Container(width: 150.0,child: Text(block.previousHash),)],),



                            ListTile(
                              title: Text('Block ${block.index}'),
                              subtitle: Text(block.data),
                              trailing: block.valid ? Icon(Icons.check,color: Colors.green,) : Icon(Icons.close,color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
