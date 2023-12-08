# SharedAccount Contract

## Description

Le contrat `SharedAccount` est un contrat intelligent Ethereum conçu pour gérer un compte partagé entre deux utilisateurs. Ce contrat permet des dépôts, des demandes de retrait, et des approbations de retrait, avec un contrôle d'accès pour que seuls les utilisateurs autorisés puissent interagir avec le compte.

## Installation et Configuration

Pour cloner et installer le projet :

```bash
git clone https://github.com/BaldeAl/sharedwallet.git
cd sharedwallet
```

## Tests

Pour exécuter les tests du contrat en utilisant Foundry :

```bash
forge test
```

Pour vérifier la couverture des tests sur l'ensemble du contrat :

```bash
forge test --coverage
```

## Déploiement du Contrat

Pour déployer le contrat sur le réseau Ethereum Sepolia, utilisez la commande suivante avec Foundry :

```bash
forge create --rpc-url VOTRE_RPC_URL -e VOTRE_ETHERSCAN_API_KEY ./src/sharedAccount/SharedAccount.sol:SharedAccount --constructor-args "ADRESSE_USER1" "ADRESSE_USER2" --verify -i
```

Remplacez `VOTRE_RPC_URL` par votre URL RPC pour Sepolia et `VOTRE_ETHERSCAN_API_KEY` par votre clé API Etherscan. Remplacez également `ADRESSE_USER1` et `ADRESSE_USER2` par les adresses Ethereum des deux utilisateurs.

## Fonctions du Contrat

### Constructor

Initialise le contrat avec les adresses des deux utilisateurs autorisés.

```solidity
constructor(address _user1, address _user2)
```

### Deposit

Permet à un utilisateur autorisé de déposer des fonds dans le compte partagé.

```solidity
function deposit() public payable onlyUsers
```

### RequestWithdrawal

Permet à un utilisateur de demander un retrait de fonds vers une adresse spécifique.

```solidity
function requestWithdrawal(uint256 amount, address payable destination) public onlyUsers
```

### ApproveWithdrawal

Permet à l'autre utilisateur d'approuver une demande de retrait.

```solidity
function approveWithdrawal(address requester) public onlyUsers
```

### GetSharedBalance

Renvoie le solde total du compte partagé.

```solidity
function getSharedBalance() public view returns (uint256)
```

### GetPendingWithdrawal

Renvoie les détails d'une demande de retrait en attente pour un utilisateur donné.

```solidity
function getPendingWithdrawal(address requester) public view returns (uint256, address)
```

## Événements

- **Deposit**
- **RequestWithdrawal**
- **ApproveWithdrawal**

## Utilisation du contrat côté frontend avec une app en vite
Une fois le contrat deployée rendez-vous sur ce depot git du frontend " https://github.com/BaldeAl/wallet_multi_signature " et suivez les instructions

## 👉le lien de mon contrat deployé : https://sepolia.etherscan.io/address/0xB56ebdb5dd4DEE6bb2e0cbbdEDfaF27fCA6e4f09

## un petit aperçu du contrat que j'ai deployé
![image](https://github.com/BaldeAl/sharedwallet/assets/79581163/ff878bae-22e0-4c06-97f6-9275b432adf4)
![image](https://github.com/BaldeAl/sharedwallet/assets/79581163/f000529f-e940-4ef9-9e55-fea1e2cc9c6c)
![image](https://github.com/BaldeAl/sharedwallet/assets/79581163/00f63e4e-21da-42fc-92d0-44dfb6ba634c)
![image](https://github.com/BaldeAl/sharedwallet/assets/79581163/24244ebc-eaff-4081-804c-08f2c3eb556e)
![image](https://github.com/BaldeAl/sharedwallet/assets/79581163/a38bdccf-7dcb-4490-a0ce-7f580db3c908)


