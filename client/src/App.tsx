import React from "react";
import "./App.css";
import WalletHeader from "./components/walletHeader";
import NFTList from "./components/NFTList";

function App() {
  const address: string = "0x5d7aaa862681920ea4f350a670816b0977c80b37";
  return (
    <div className="App">
      <header className="App-header">
        <WalletHeader />
      </header>
      <body>
        <NFTList address={address} />
      </body>
    </div>
  );
}

export default App;
