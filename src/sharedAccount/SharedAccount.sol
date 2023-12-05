// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SharedAccount {
    address public user1;
    address public user2;
    uint256 public sharedBalance;

    // Structure pour stocker les informations de retrait
    struct WithdrawalRequest {
        uint256 amount;
        address payable destination;
    }
    // Mapping pour stocker les demandes de retrait
    mapping(address => WithdrawalRequest) public pendingWithdrawals;

    // les events pour deposit, requestWithdrawal et approveWithdrawal avec les informations necessaires
    event Deposit(address indexed user, uint256 amount);
    event RequestWithdrawal(
        address indexed user,
        uint256 amount,
        address destination
    );
    event ApproveWithdrawal(
        address indexed requester,
        address indexed approver,
        uint256 amount
    );

    // Constructeur pour initialiser les deux utilisateurs
    constructor(address _user1, address _user2) {
        user1 = _user1;
        user2 = _user2;
    }

    // Modifier pour verifier que l'adresse qui appelle la fonction est un des deux utilisateurs
    modifier onlyUsers() {
        require(msg.sender == user1 || msg.sender == user2, "Non autorise");
        _;
    }

    // Fonction pour deposer de l'argent dans le contrat
    function deposit() public payable onlyUsers {
        sharedBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Fonction pour demander un retrait  d'un montant vers une destination
    function requestWithdrawal(
        uint256 amount,
        address payable destination
    ) public onlyUsers {
        require(amount > 0, "Montant doit etre superieur a zero");
        require(sharedBalance >= amount, "Solde partage insuffisant");

        pendingWithdrawals[msg.sender] = WithdrawalRequest(amount, destination);

        emit RequestWithdrawal(msg.sender, amount, destination);
    }

    // Fonction pour approuver un retrait d'un montant pour un utilisateur donné
    function approveWithdrawal(address requester) public onlyUsers {
        require(
            msg.sender != requester,
            "Ne peut pas approuver son propre retrait"
        );
        WithdrawalRequest storage request = pendingWithdrawals[requester];
        require(request.amount > 0, "Pas de retrait en attente");

        request.destination.transfer(request.amount);
        sharedBalance -= request.amount;
        pendingWithdrawals[requester] = WithdrawalRequest(
            0,
            payable(address(0))
        );
        emit ApproveWithdrawal(requester, msg.sender, request.amount);
    }

    // Fonction pour recuperer le solde partage
    function getSharedBalance() public view returns (uint256) {
        return sharedBalance;
    }

    // Fonction pour recuperer le retrait en attente d'un utilisateur
    function getPendingWithdrawal(
        address requester
    ) public view returns (uint256, address) {
        WithdrawalRequest storage request = pendingWithdrawals[requester];
        return (request.amount, request.destination);
    }
}
