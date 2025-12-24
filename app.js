const connectButton = document.getElementById("connectButton");
const accountDisplay = document.getElementById("account");

connectButton.onclick = async () => {
  if (typeof window.ethereum === "undefined") {
    alert("MetaMask n'est pas installé");
    return;
  }

  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const accounts = await provider.send("eth_requestAccounts", []);
    const signer = await provider.getSigner();

    accountDisplay.innerText = "Connecté : " + accounts[0];
  } catch (error) {
    console.error(error);
    alert("Connexion refusée");
  }
};
