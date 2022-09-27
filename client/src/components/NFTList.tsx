import { useEffect, useState } from "react";

function NFTList({ address }: { address: string }) {
  const [nfts, setNfts] = useState([]);

  useEffect(() => {
    const options = {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: "",
      },
    };

    fetch(
      "https://api.nftport.xyz/v0/accounts/0x5D7aAa862681920Ea4f350a670816b0977c80B37?chain=ethereum&include=metadata",
      options
    )
      .then((response) => response.json())
      .then((response) => {
        setNfts(response.nfts);
      })
      .catch((err) => console.error(err));
  }, [address]);

  return (
    <div>
      <ul>
        {nfts.map((nft: any, index) => (
          <li key={index}>
            <img src={nft.file_url} alt={nft.name} />
            <p>{nft.name}</p>
            <p>{nft.description}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default NFTList;
